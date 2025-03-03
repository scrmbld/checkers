---This file includes a test/demo program for the widgets module it is contianed in.
UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 64)

local Board = require("board")
local Timer = require("timer")
local Settings = require("settings")

local Widgets = require "widgets"
-- we import this so that we can make scenes and whatnot
-- the Widgets module requires us to make both a scene and a pointer ourselves
local Inky = require("widgets.inky")

local scene = Inky.scene()
local pointer = Inky.pointer(scene)

local function greet()
	print("hi!")
end

---Go to the main menu, ending any existing game
local function mainMenu()
	game_board.active = false
	pause_menu.active = false
	settings_menu.active = false

	main_menu.active = true
end

---Start a new game and hide the menu
local function newGame()
	print("new game")
	main_menu.active = false
	pause_menu.active = false
	settings_menu.active = false

	-- initialize game board
	game_board = Board:new(20, 20)
	game_board.active = true
end

local function Pause()
	main_menu.active = false
	game_board.active = false
	settings_menu.active = false

	pause_menu.active = true
end

local function Unpause()
	pause_menu.active = false
	main_menu.active = false
	settings_menu.active = false

	game_board.active = true
end

local function openSettings()
	pause_menu.active = false
	main_menu.active = false
	game_board.active = false

	settings_menu.active = true
end

local function closeSettings()
	settings_menu.active = false
	pause_menu.active = false
	game_board.active = false

	main_menu.active = true

	GameSettings:Revert()
end

local function toggleFullscreen()
	GameSettings.fullscreen = not GameSettings.fullscreen
	local new_text = ""
	if GameSettings.fullscreen then
		new_text = "Fullscreen"
	else
		new_text = "Windowed"
	end

	print(new_text)

	settings_menu.buttons[1]:SetText(new_text)
end

local function applySettings()
	if settings_menu ~= nil then
		GameSettings.current_res_index = settings_menu.buttons[2].options_index
	end
	GameSettings:Apply()
end

---Calling this signals that the current game has ended
function GameOver(result_text)
	main_menu.title = result_text
	main_menu.active = true
	game_board.game_timer:stop()
end

function love.load()
	GameSettings = Settings:New()
	GameSettings:Apply()


	-- initialize main menu
	local menu_buttons = {
		{ text = "New Game", onClick = newGame,         type = "button" },
		{ text = "Settings", onClick = openSettings,    type = "button" },
		{ text = "Exit",     onClick = love.event.quit, type = "button" },
	}
	local pause_buttons = {
		{ text = "Resume",   onClick = Unpause,         type = "button" },
		{ text = "New Game", onClick = newGame,         type = "button" },
		{ text = "Settings", onClick = openSettings,    type = "button" },
		{ text = "Exit",     onClick = love.event.quit, type = "button" }
	}
	local fullscreen_text = ""
	if GameSettings.fullscreen then
		fullscreen_text = "Fullscreen"
	else
		fullscreen_text = "Windowed"
	end
	local settings_buttons = {
		{ text = fullscreen_text,                     onClick = toggleFullscreen,                   type = "button" },
		{ options = GameSettings.allowed_resolutions, start_index = GameSettings.current_res_index, type = "arrowSelector" },
		{ text = "Apply",                             onClick = applySettings,                      type = "button" },
		{ text = "Back",                              onClick = closeSettings,                      type = "button" },
	}

	main_menu = Widgets.menu:New(scene, "Checkers", 20, 20, 1, menu_buttons)
	pause_menu = Widgets.menu:New(scene, "Paused", 20, 20, 1, pause_buttons)
	settings_menu = Widgets.menu:New(scene, "Settings", 20, 20, 1, settings_buttons)

	-- initialize game board
	game_board = Board:new(20, 20)

	-- we should start on the main menu
	mainMenu()
end

function love.update(delta)
	if game_board.active then
		game_board:update(delta)
	end

	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
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
	-- adjust for scaling
	x = x / GameSettings.scaleFactor
	y = y / GameSettings.scaleFactor

	if game_board.active then
		game_board:mousepressed(x, y, button)
	end

	if button == 1 then
		pointer:raise("press")
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		pointer:raise("release")
	end
end

function love.draw()
	love.graphics.scale(GameSettings.scaleFactor, GameSettings.scaleFactor)
	game_board:draw()

	love.graphics.origin()
	scene:beginFrame()
	if main_menu.active then
		main_menu:draw()
	end
	if pause_menu.active then
		pause_menu:draw()
	end
	if settings_menu.active then
		settings_menu:draw()
	end
	scene:finishFrame()
end
