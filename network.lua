require "enet"

local M = {}

local client = {}
local server = {}
local address = "localhost:6789"

-- In love.load
function M.init()
	local error_message
	server.host, error_message = enet.host_create (address)

	if not server.host then
		print ("Running in client mode")
		server = nil
	else
		print ("Server: listening...")
		client = nil
	end

	if client then
		print ("Client: connecting to server: " .. address)
		client.host = enet.host_create()
		client.host:connect (address)

		client.counter = 0
		client.peer = false
		client.connect_timestamp = 0
		client.duration = 10
		client.last_message_timestamp = 0
	end
end

function server_list_peers()
	if server.host:peer_count() <= 0 then
		return
	end

	print ("list of peers:")

	local i = 1
	while i < server.host:peer_count() + 1 do
		local p = server.host:get_peer(i)
		print ("  " .. i .. " : " .. tostring(p) .. " state: " .. p:state() .. " connectID: " .. tostring (p:connect_id()))
		i = i + 1
	end
end

local server_peer = {}

function server_update ()
	local event = server.host:service()

	while event ~= nil do
		if event.type == "receive" then
			print ("Server: got message: ", event.data, event.peer)
			event.peer:send(event.data)
			local limit, minimum, maximum = event.peer:timeout(5, 800, 1200);
		elseif event.type == "connect" then
			print ("Server: got a new connection (peer count = " .. server.host:peer_count() .. "). Peer index = " .. event.peer:index())
			server_list_peers()
			server_peer = event.peer
		elseif event.type == "disconnect" then
			print ("Server: lost connection to peer: " .. tostring(event.peer) .. " (peer count = " .. server.host:peer_count() .. ")")
		end

		event = server.host:service()
	end
end

function client_update (dt)
	local event = client.host:service()

	while event ~= nil do
		if event.type == "connect" then
			print ("Client: connected to: " .. tostring(event.peer))
			client.peer = event.peer
			client.connect_timestamp = love.timer.getTime()

			event.peer:send("Hello server")
			client.last_message_timestamp = love.timer.getTime()

			print ("Client: initializing ping interval   = " .. event.peer:ping_interval (500))
			print ("Client: Initializing round_trip_time = " .. client.peer:round_trip_time (50))

			local limit, minimum, maximum = client.peer:timeout(16, 1000, 1500);
		elseif event.type == "disconnect" then
			print ("Client: Disconnected from Server!")
			love.event.push("quit")
		elseif event.type == "receive" then
			print ("Client: received message: ", event.data, event.peer)
			client.counter = client.counter + 1
		end

		event = client.host:service()
	end

	-- actions that are done every second
	if client.peer and math.floor (love.timer.getTime() - client.last_message_timestamp) > 0 then
		client.last_message_timestamp = love.timer.getTime()
		client.peer:send("Packet " .. tostring (client.counter))
	end
end

-- In love.update
function M.update(dt)
	if server then
		server_update (dt)
	end

	if client then
		client_update (dt)
	end
end

function love.keypressed(key, code)
	print ("got key: " .. key)

	if (key == "escape") then
		love.event.push("quit")
	end
end

return M
