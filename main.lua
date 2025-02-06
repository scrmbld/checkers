function love.load()
	UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 64)

	Board = require("board")
	Timer = require("timer")
	love.window.setMode(1920, 1320)

	-- create a board
	game_board = Board:new(20, 20)
	-- create a timer (NOTE: it may be appropriate to move this to the Board class in the future)
end

function love.update(delta)
	game_board:update(delta)
end

function love.mousepressed(x, y, button)
	game_board:mousepressed(x, y, button)
end

function love.draw()
	game_board:draw()
end
