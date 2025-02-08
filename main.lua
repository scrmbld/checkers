local function greet()
	print("hi!")
end

---Go to the main menu, ending any existing game
local function mainMenu()
	main_menu.active = true
	game_board.active = false
	pause_menu.active = false
end

---Start a new game and hide the menu
local function newGame()
	main_menu.active = false
	pause_menu.active = false

	-- initialize game board
	game_board = Board:new(20, 20)
	game_board.active = true
end

local function Pause()
	main_menu.active = false
	game_board.active = false

	pause_menu.active = true
end

local function Unpause()
	pause_menu.active = false
	main_menu.active = false

	game_board.active = true
end

---Calling this signals that the current game has ended
function GameOver(result_text)
	main_menu.title = result_text
	main_menu.active = true
	game_board.game_timer:stop()
end

function love.load()
	UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 64)

	-- find the scale factor by which we should scale every love.graphics.draw
	local base_resx = 1680
	local base_resy = 1320
	local resx = 1280
	local resy = 720
	ScaleFactor = resx / base_resx
	if resy / base_resy < ScaleFactor then
		ScaleFactor = resy / base_resy
	end

	Board = require("board")
	Timer = require("timer")
	Menu = require("menu")

	love.window.setMode(resx, resy)

	-- initialize main menu
	local menu_buttons = {
		{ "New Game", newGame },
		{ "Exit",     love.event.quit }
	}
	local pause_buttons = {
		{ "Resume",   Unpause },
		{ "New Game", newGame },
		{ "Exit",     love.event.quit }
	}

	main_menu = Menu:new(20, 20, "Checkers", menu_buttons)
	pause_menu = Menu:new(20, 20, "Game Paused", pause_buttons)

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

function love.keypressed(key, scancode, isrepeat)
	if game_board.active and key == "escape" and isrepeat == false then
		print("pause")
		Pause()
		return
	end
	if pause_menu.active and key == "escape" and isrepeat == false then
		print("unpause")
		Unpause()
		return
	end
end

function love.mousepressed(x, y, button)
	if game_board.active then
		game_board:mousepressed(x, y, button)
	end
	if main_menu.active then
		main_menu:mousepressed(x, y, button)
	end
	if pause_menu.active then
		pause_menu:mousepressed(x, y, button)
	end
end

function love.draw()
	game_board:draw()

	if main_menu.active then
		main_menu:draw()
	end
	if pause_menu.active then
		pause_menu:draw()
	end
end
