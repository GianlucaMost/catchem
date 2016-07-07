local network = require "network"
gameTime = 0
players = { }
obstacles = { }
obstacleNames = { "blue", "darkgray", "gray", "green", "lightblue", "orange", "pink", "purple", "red", "red2", "white" }
playerSpeed = 200
menu = true

function love.load()
	math.randomseed(os.time())
end

function generate()
	player = {
		x = 512,
		y = 512,
		image = love.graphics.newImage('assets/nyan_cat.png'),
		name = "first"
	}
	table.insert(players, player)

	player2 = {
		x = 256,
		y = 256,
		image = love.graphics.newImage('assets/nyan_dog.png'),
		name = "second"
	}

	table.insert(players, player2)

	for i=1, 2 + math.random(8) do
		obstacle = {
			x = 400,
			y = 400,
			image = love.graphics.newImage(randomObstacle());
		}
		randomPosition(obstacle)

		table.insert(obstacles, obstacle)
	end

  network.init()
end

background = love.graphics.newImage ("/assets/background.png")
function love.draw()
	if menu then
		love.graphics.print("Press S to create a server, press C to connect");
	else
		for i = 0, love.graphics.getWidth() / background:getWidth() do
	    for j = 0, love.graphics.getHeight() / background:getHeight() do
	      love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
	    end
	  end
		for i, player in ipairs(players) do
			love.graphics.draw(player.image, player.x, player.y)
		end
		for i, obst in ipairs(obstacles) do
			love.graphics.draw(obst.image, obst.x, obst.y)
		end
	end
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
	menu = false;
end

function connectToServer()
	menu = false;
end

function whatToDo()
	if love.keyboard.isDown('s') then
		startServer()
	end
	if love.keyboard.isDown('c') then
		connectToServer()
	end
end

function love.update(dt)
	if menu then
	  whatToDo()
	else
	  gameTime = gameTime + dt
	  for i, p in ipairs(players) do
		if not i == 0 then
			p.x = math.sin(gameTime)*100
		end
	  end

	 movement(dt)

	end

	--network.update()


 if love.keyboard.isDown('escape') then
	love.event.push('quit')
  end

end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end

function randomObstacle()
	path = "assets/colorblocks/" .. obstacleNames[math.random(1, table.getn(obstacleNames))] .. ".png"
	print(path)
	return path
end
