require "enet"
local str = require "strings"
gameTime = 0
haunted = { }
hunters = { }
obstacles = { }
obstacleNames = { "blue", "darkgray", "gray", "green", "lightblue", "orange", "pink", "purple", "red", "red2", "white" }
bgm = love.audio.newSource("assets/sounds/music/nyan_sound.mp3", "stream")
bgm:setVolume(0.5)
playerSpeed = 200
menu = true
debugMode = true
server = false
idCount = 0


local client = {}
local server = {}
local address = "localhost:6789"

maxDistanceSquared = 40000;
mayHuntersSeeHunters = true;

function love.load()
	math.randomseed(os.time())
end

function generate()

	for i=1, 2 + math.random(8) do
		obstacle = {
			x = 0,
			y = 0,
			image = love.graphics.newImage(randomObstacle());
		}
		randomPosition(obstacle)

		table.insert(obstacles, obstacle)
	end

	player = {
    id = idCount,
		x = 0,
		y = 0,
		image = love.graphics.newImage('assets/nyan_dog.png'),
		hunter = true;
	}
	randomPosition(player)
	table.insert(hunters, player)
  idCount = idCount + 1

	for i=1, 2 + math.random(8) do
    path = randomObstacle()
		obstacle = {
			x = 400,
			y = 400,
			image = love.graphics.newImage(path),
      imagePath = path;
		}
		randomPosition(obstacle)

		table.insert(obstacles, obstacle)
	end
end

function generatePlayer()
  player2 = {
    id = idCount,
		x = 512,
		y = 512,
		image = love.graphics.newImage('assets/nyan_cat.png'),
		hunter = false
	}
	table.insert(hunters, player2)
  idCount = idCount + 1
  return player2
end

function serializePlayer(player, isCurrentPlayer)
  return "Player," .. isCurrentPlayer .. "," .. player.id .. "," .. player.x .. "," .. player.y .. ","  .. player.hunter
end

function serializeObstacles()
  message = "Obstacles"
  for i,v in ipairs(obstacles) do
    message = message .. "," .. v.x .. "," .. v.y .. "," .. v.imagePath
  end
end

background = love.graphics.newImage ("/assets/background.png")

function love.draw()
	if menu then
		love.graphics.print("Press S to create a server, press C to connect", 530, 300);
	else
		for i = 0, love.graphics.getWidth() / background:getWidth() do
	    for j = 0, love.graphics.getHeight() / background:getHeight() do
	      love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
	    end
	  end
		for i, p in ipairs(hunters) do
			if debugMode or (player.hunter and mayHuntersSeeHunters) or (calcDistanceSquared(player, p) < maxDistanceSquared) then
				love.graphics.draw(p.image, p.x, p.y)
			end
		end
		for i, p in ipairs(haunted) do
			if debugMode or calcDistanceSquared(player, p) < maxDistanceSquared then
				love.graphics.draw(p.image, p.x, p.y)
			end
		end
		for i, obst in ipairs(obstacles) do
			love.graphics.draw(obst.image, obst.x, obst.y)
		end
		love.audio.play(bgm)
	end
end

function calcDistanceSquared(object1, object2)
	xCenter1 = object1.x + object1.image:getWidth() / 2;
	yCenter1 = object1.y + object1.image:getHeight() / 2;
	xCenter2 = object2.x + object2.image:getWidth() / 2;
	yCenter2 = object2.y + object2.image:getHeight() / 2;

	return (xCenter1-xCenter2)*(xCenter1-xCenter2) + (yCenter1 - yCenter2) * (yCenter1 - yCenter2);
end

function movement(dt)
  xBefore = player.x;
  yBefore = player.y;

  if love.keyboard.isDown('down', 's') then
        if player.y < (love.graphics.getHeight() - player.image:getHeight()) then
            player.y = player.y + (playerSpeed*dt)
        end
    elseif love.keyboard.isDown('up', 'w') then
        if player.y > 0 then
            player.y = player.y - (playerSpeed*dt)
        end
    end

    if love.keyboard.isDown('left','a') then
        if player.x > 0 then -- binds us to the map
            player.x = player.x - (playerSpeed*dt)
        end
    elseif love.keyboard.isDown('right','d') then
        if player.x < (love.graphics.getWidth() - player.image:getWidth()) then
            player.x = player.x + (playerSpeed*dt)
        end
    end

		if checkObstackleCollision(player) then
			player.x = xBefore;
			player.y = yBefore;
		end
end

function randomPosition(object)
	repeat
		object.x = math.random(0, love.graphics.getWidth() - 1 - object.image:getWidth())
		object.y = math.random(0, love.graphics.getHeight() - 1 - object.image:getHeight())
	until not checkObstackleCollision(object)
end

function checkObstackleCollision(object)
	for i, obst in ipairs(obstacles) do
		if checkCollision(object.x, object.y, object.image:getWidth(), object.image:getHeight(), obst.x, obst.y, obst.image:getWidth(), obst.image:getHeight()) then
			return true
		end
	end
	return false
end

function startServer()
	generate()
  init(true)
	menu = false;
	server = true
	--start listening for clients and send them everything
	--for a new client create a new haunted
	-- when all haunted are hunters: Restart: One random hunter, that is stunned 4 seconds
end

function connectToServer()
  init(false)
  generatePlayer()
	server = false
	-- Set Variable player
	-- Get other players and obstacles from server
end

function whatToDo()
	if love.keyboard.isDown('s') then
		startServer()
	end
	if love.keyboard.isDown('c') then
		connectToServer()
	end
end

function collision()
	for i, hu in ipairs(hunters) do
		for j, ha in ipairs(haunted) do
			if checkObjectCollision(hu, ha) then
				table.insert(hunters, ha)
				table.remove(haunted, j)
				ha.hunter = true
        -- TODO Clients informieren
			end
		end
	end
end

function love.update(dt)
	if menu then
	  whatToDo()
	else
		gameTime = gameTime + dt
		for i, p in ipairs(haunted) do
			if not i == 0 then
				p.x = math.sin(gameTime)*100
			end
		end

		movement(dt)
		if server then
			collision()
			if table.getn(haunted) == 0 then
				print("Ende")
				--TODO restart
				--TODO set all haunted back to hunter = false
			end
		end

	end

	--network.update()


	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

end

function checkObjectCollision(object1, object2)
	return checkCollision(object1.x, object1.y, object1.image:getWidth(), object1.image:getHeight(), object2.x, object2.y, object2.image:getWidth(), object2.image:getHeight())
end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end

function randomObstacle()
	path = "assets/colorblocks/" .. obstacleNames[math.random(1, table.getn(obstacleNames))] .. ".png"
	return path
end

-- In love.load
function init(isServer)
	local error_message
	server.host, error_message = enet.host_create (address)

	if not isServer then
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
      player2 = generatePlayer()
      event.peer:send(serializePlayer(player2, true))
      for i,v in ipairs(hunters) do
        if not v.id == player2.id then
          event.peer:send(serializePlayer(v, false))
        end
      end
      for i,v in ipairs(haunted) do
        if not v.id == player2.id then
          event.peer:send(serializePlayer(v, false))
        end
      end
      event.peer:send(serializeObstacles())
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
      processMessage(event.data)
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
function update(dt)
	if server then
		server_update (dt)
	end

	if client then
		client_update (dt)
	end
end

function sendMessage(message)
  local event = client.host:service()
  client.peer = event.peer
  event.peer:send(message)
end

function processMessage(message)
  splitted = str.split(message,",")
  if splitted[1] == "Player" then
    p = {
      id = splitted[3],
      x = splitted[4],
      y = splitted[5],
      image = love.graphics.newImage('assets/nyan_cat.png'),
      hunter = splitted[6];
    }
    if splitted[2] == "true" then
      player = p
    end
    if splitted[6] == "true" then
      p.image = love.graphics.newImage('assets/nyan_dog.png')
        table.insert(hunters, p)
    else
      table.insert(haunted, p)
    end
  elseif splitted[1] == "Obstacles" then
    count = 0
    for i,v in ipairs(splitted) do
      if not i == 1 then
        if count == 0 then
          obstacleX = v
        elseif count == 1 then
          obstacleY = v
        elseif count == 2 then
          obstacleImagePath = v
          obstacle = {
      			x = obstacleX,
      			y = obstacleY,
      			image = love.graphics.newImage(obstacleImagePath),
            imagePath = obstacleImagePath;
      		}

      		table.insert(obstacles, obstacle)
          count = 0
        end
      end
    end
    	menu = false
  end
end

function love.keypressed(key, code)
	print ("got key: " .. key)

	if (key == "escape") then
		love.event.push("quit")
	end
end
