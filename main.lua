gameTime = 0
players = { }
playerSpeed = 100;

function love.load()
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
end

function love.draw()
	for i, player in ipairs(players) do
        love.graphics.draw(player.image, player.x, player.y)
    end
end

function love.update(dt)
  gameTime = gameTime + dt
  for i, p in ipairs(players) do
		  if not i == 0 then
        p.x = math.sin(gameTime)*100
			end
  end

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
end
