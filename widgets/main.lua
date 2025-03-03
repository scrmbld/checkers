local Inky = require("inky")

local Menu = require("menu")
local Selector = require("arrow_selector")

UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 64)

local scene = Inky.scene()
local pointer = Inky.pointer(scene)

local function sayHi()
	print("hi!")
end

local function sayGreetings()
	print("greetings!")
end

local text_options = {
	1,
	2,
	3
}
local selector_1 = Selector:New(scene, 50, 100, 300, 60, text_options)

local function printSelected()
	print(selector_1:getSelected())
end

local buttons = {
	{ text = "Print Selected", onClick = printSelected },
	{ text = "Button 2",       onClick = sayGreetings }
}

local menu_1 = Menu:New(scene, "Menu", 400, 100, 1, buttons)

function love.load()
	love.window.setMode(1280, 1024)
	love.window.setTitle("Example: getting started")
end

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	scene:beginFrame()

	menu_1:draw()
	selector_1:draw()

	scene:finishFrame()
end

function love.mousepressed(x, y, button)
	if button == 1 then
		pointer:raise("press")
	end
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end
