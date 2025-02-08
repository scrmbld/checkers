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

	newObj.width = newObj.sp_button:getWidth() * ScaleFactor
	newObj.height = newObj.sp_button:getHeight() * ScaleFactor

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
	love.graphics.draw(self.sp_button, self.x, self.y, 0, ScaleFactor, ScaleFactor)
	love.graphics.draw(self.text_display, self.x + 20 * ScaleFactor, self.y + 20 * ScaleFactor, 0, 0.5 * ScaleFactor,
		0.5 * ScaleFactor)
end

function Menu:new(x, y, title, buttons)
	local newObj = {
		x = x,
		y = y,
		sp_body = love.graphics.newImage("images/dark_menu.png"),

		title = title,
		buttons = {},

		active = false
	}

	newObj.width = newObj.sp_body:getWidth() * ScaleFactor
	newObj.height = newObj.sp_body:getHeight() * ScaleFactor

	newObj.title_display = love.graphics.newText(font, { { 1, 1, 1, 1 }, newObj.title })

	if buttons ~= nil then
		newObj.buttons = {}
		for i, v in ipairs(buttons) do
			-- Menu origin + title text height + button image margin + button height
			local new_button = Button:new(newObj.x + (40 * ScaleFactor),
				newObj.y + (100 * ScaleFactor) + (40 * ScaleFactor) + 120 * (i - 1) * ScaleFactor, v[1], v[2])
			newObj.buttons[#newObj.buttons + 1] = new_button
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
	love.graphics.draw(self.sp_body, self.x, self.y, 0, ScaleFactor, ScaleFactor)

	-- update title text, just in case
	self.title_display:set(self.title)
	love.graphics.draw(self.title_display, self.x + (25 * ScaleFactor), self.y + (40 * ScaleFactor), 0, 0.8 * ScaleFactor,
		0.8 * ScaleFactor)

	if self.buttons ~= nil and #self.buttons > 0 then
		for i, v in ipairs(self.buttons) do
			v:draw()
		end
	end
end

return Menu
