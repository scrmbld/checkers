function love.load()
	Board = require("board")
	Timer = require("timer")
	love.window.setMode(1920, 1320)

	-- create a board
	game_board = Board:new(20, 20)
	-- create a timer (NOTE: it may be appropriate to move this to the Board class in the future)
	game_timer = Timer:new(game_board.x + game_board.width + 20, 20, 600, 0)
	game_timer:start(1)
end

function love.update(delta)
	game_timer:update(delta)
end

function love.mousepressed(x, y, button)
	game_board:mousepressed(x, y, button)
end

function love.draw()
	game_board:draw()
	game_timer:draw()
end
