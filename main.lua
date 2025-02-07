local function greet()
	print("hi!")
end

--- Go to the main menu, ending any existing game
local function mainMenu()
	main_menu.active = true
	game_board.active = false
end

local function newGame()
	main_menu.active = false
	game_board.active = true
end

function love.load()
	UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 64)

	Board = require("board")
	Timer = require("timer")
	Menu = require("menu")

	love.window.setMode(1920, 1320)

	-- initialize main menu
	main_menu = Menu:new(20, 20, "Hello World!", { { "Hi There!", newGame } })

	-- initialize game board
	game_board = Board:new(20, 20)

	-- we should start on the main menu
	mainMenu()
end

function love.update(delta)
	if game_board.active then
		game_board:update(delta)
	end
end

function love.mousepressed(x, y, button)
	if game_board.active then
		game_board:mousepressed(x, y, button)
	end
	if main_menu.active then
		main_menu:mousepressed(x, y, button)
	end
end

function love.draw()
	if game_board.active then
		game_board:draw()
	end
	if main_menu.active then
		main_menu:draw()
	end
end
