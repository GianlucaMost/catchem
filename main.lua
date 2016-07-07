gameTime = 0
players = { }

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
	
	table.insert(players, player)
end

function love.draw()
	for i, player in ipairs(players) do
        love.graphics.draw(player.image, player.x, player.y)
    end
end

function love.update(dt)
  gameTime = gameTime + dt
  for i, player in ipairs(players) do
        player.x = math.sin(gameTime)*100
  end
end
