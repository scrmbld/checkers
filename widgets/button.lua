local PATH = (...):gsub("%.button$", "")
local Inky = require(PATH .. ".inky")
local Utils = require(PATH .. ".utils")


local ButtonVisuals = {
	sp_left = love.graphics.newImage(PATH .. "/images/button_left.png"),
	sp_right = love.graphics.newImage(PATH .. "/images/button_right.png"),
	sp_center = love.graphics.newImage(PATH .. "/images/button_center.png"),
	sp_pressed_left = love.graphics.newImage(PATH .. "/images/button_pressed_left.png"),
	sp_pressed_right = love.graphics.newImage(PATH .. "/images/button_pressed_right.png"),
	sp_pressed_center = love.graphics.newImage(PATH .. "/images/button_pressed_center.png"),
}

ButtonVisuals.base_height = ButtonVisuals.sp_center:getHeight()
ButtonVisuals.base_width = ButtonVisuals.sp_left:getWidth() + ButtonVisuals.sp_center:getWidth() +
	ButtonVisuals.sp_right:getWidth()

local IButton = Inky.defineElement(function(self)
	return function(_, x, y, w, h)
		local scale_y = h / ButtonVisuals.base_height
		local ends_width = (ButtonVisuals.sp_left:getWidth() + ButtonVisuals.sp_right:getWidth()) * scale_y
		local middle_target = w - ends_width
		local scale_x = middle_target / ButtonVisuals.sp_center:getWidth()

		local pixel_offset = 0

		if self.props.held == false then
			love.graphics.draw(ButtonVisuals.sp_left, x, y, 0, scale_y, scale_y)
			local middle_x = ButtonVisuals.sp_left:getWidth() * scale_y
			love.graphics.draw(ButtonVisuals.sp_center, x + middle_x, y, 0, scale_x, scale_y)
			local right_x = middle_x + ButtonVisuals.sp_center:getWidth() * scale_x
			love.graphics.draw(ButtonVisuals.sp_right, x + right_x, y, 0, scale_y, scale_y)
		else
			-- move all of the pressed button stuff by a single "pixel" (artwork pixel)
			pixel_offset = (ButtonVisuals.sp_left:getWidth() / 4) * scale_y
			love.graphics.draw(ButtonVisuals.sp_pressed_left, x + pixel_offset, y, 0, scale_y, scale_y)
			local middle_x = ButtonVisuals.sp_left:getWidth() * scale_y
			love.graphics.draw(ButtonVisuals.sp_pressed_center, x + pixel_offset + middle_x, y, 0, scale_x, scale_y)
			local right_x = middle_x + ButtonVisuals.sp_center:getWidth() * scale_x
			love.graphics.draw(ButtonVisuals.sp_pressed_right, x + pixel_offset + right_x, y, 0, scale_y, scale_y)
		end

		local base_text_width, base_text_height = self.props.displayText:getDimensions()
		local text_scale = (ButtonVisuals.sp_center:getWidth() / base_text_width) * scale_x
		if text_scale > 1 then text_scale = 1 end
		local text_x, text_y = Utils.centerText(w, h, base_text_width * text_scale, base_text_height * text_scale)
		love.graphics.draw(self.props.displayText, x + pixel_offset + text_x, y + pixel_offset + text_y, 0, text_scale,
			text_scale)
	end
end)

local Button = {
	name = "Button"
}

function Button:New(scene, text, x, y, width, height, onClick)
	local newObj = {
		text = text,
		x = x,
		y = y,
		width = width,
		height = height,
		onClick = onClick,
	}

	local i_button = IButton(scene)
	newObj.inky_obj = i_button
	newObj.inky_obj.props.held = false

	newObj.inky_obj:onPointer("press", function(s)
		s.props.held = true
	end)
	newObj.inky_obj:onPointer("release", function(s)
		s.props.held = false
		onClick()
	end)
	newObj.inky_obj.props.displayText = love.graphics.newText(UnifontEX,
		{ { 0.1, 0.1, 0.1, 1.0 }, newObj.text })

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

function Button:draw()
	self.inky_obj:render(self.x, self.y, self.width, self.height)
end

function Button:SetText(new_text)
	self.text = new_text
	self.inky_obj.props.displayText:set({ { 0.1, 0.1, 0.1, 1.0 }, self.text })
end

return Button
