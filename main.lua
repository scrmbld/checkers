function love.load()
	Board = require("board")
	love.window.setMode(1320, 1320)

	-- create a board
	game_board = Board:new(20, 20)
end

function love.mousepressed(x, y, button)
	game_board:mousepressed(x, y, button)
end

function love.draw()
	game_board:draw()
end
