local Menu = {
	name = "Menu"
}

local font = UnifontEX

-- This is used inside of Menu
local Button = {
	name = "Button"
}

function Button:new(x, y, text_content, callback)
	local newObj = {
		x = x,
		y = y,
		sp_button = love.graphics.newImage("images/button.png"),
		sp_pressed = love.graphics.newImage("images/button_pressed.png"),

		text_content = text_content,

		callback = callback,
	}

	newObj.width = newObj.sp_button:getWidth()
	newObj.height = newObj.sp_button:getHeight()

	newObj.text_display = love.graphics.newText(font, { { 0, 0, 0, 1 }, newObj.text_content })

	self.__index = self

	setmetatable(newObj, self)

	return newObj
end

function Button:mousepressed(x, y, btn)
	if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height and btn == 1 then
		self.callback()
	end

	-- TODO: animate button press
end

function Button:draw()
	love.graphics.draw(self.sp_button, self.x, self.y)
	love.graphics.draw(self.text_display, self.x + 20, self.y + 20, 0, 0.5, 0.5)
end

function Menu:new(x, y, title, buttons)
	local newObj = {
		x = x,
		y = y,
		sp_body = love.graphics.newImage("images/dark_menu.png"),

		title_text_content = title,
		buttons = {},

		active = false
	}

	newObj.width = newObj.sp_body:getWidth()
	newObj.height = newObj.sp_body:getHeight()

	newObj.title_display = love.graphics.newText(font, { { 1, 1, 1, 1 }, newObj.title_text_content })

	if buttons ~= nil then
		newObj.buttons = {}
		for i, v in ipairs(buttons) do
			local new_button = Button:new(newObj.x + 40, newObj.y + 40 + 100 + 90 * (i - 1), v[1], v[2])
			newObj.buttons[#newObj.buttons + 1] = new_button
			print(#newObj.buttons)
		end
	end

	self.__index = self

	setmetatable(newObj, self)

	return newObj
end

function Menu:mousepressed(x, y, btn)
	if self.buttons ~= nil and #self.buttons > 0 then
		for i, v in ipairs(self.buttons) do
			v:mousepressed(x, y, btn)
		end
	end
end

function Menu:draw()
	love.graphics.draw(self.sp_body, self.x, self.y)

	love.graphics.draw(self.title_display, self.x + 25, self.y + 40, 0, 0.7, 0.7)

	if self.buttons ~= nil and #self.buttons > 0 then
		for i, v in ipairs(self.buttons) do
			v:draw()
		end
	end
end

return Menu
