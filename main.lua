gameTime = 0

function love.load()
	player = {
		x = 512,
		y = 512
	}
end

function love.draw()
	love.graphics.rectangle("fill", player.x, player.y, 32, 32)
end

function love.update(dt)
  gameTime = gameTime + dt
  player.x = 512 + math.sin(gameTime)*100
end
