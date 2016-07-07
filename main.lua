local network = require "network"
gameTime = 0
players = { }
obstacles = { }
playerSpeed = 100;

function love.load()
	math.randomseed(os.time())
	player = {
		x = 512,
		y = 512,
		image = love.graphics.newImage('assets/first.png'),
		name = "first"
	}
	table.insert(players, player)

	player2 = {
		x = 256,
		y = 256,
		image = love.graphics.newImage('assets/second.png'),
		name = "second"
	}

	table.insert(players, player2)

	firstObstacle = {
		x = 400,
		y = 400,
		image = love.graphics.newImage("assets/house.png");
	}
	randomPosition(firstObstacle)

  network.init()
end

function love.draw()
	for i, player in ipairs(players) do
        love.graphics.draw(player.image, player.x, player.y)
    end
	for i, obst in ipairs(obstacles) do
        love.graphics.draw(obst.image, obst.x, obst.y)
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

function love.update(dt)
  gameTime = gameTime + dt
  network.update()
  for i, p in ipairs(players) do
	if not i == 0 then
        p.x = math.sin(gameTime)*100
	end
  end

 movement(dt)

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
