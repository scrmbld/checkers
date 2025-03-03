local PATH = (...):gsub("%.arrow_selector$", "")
local Inky = require(PATH .. ".inky")
local Utils = require(PATH .. ".utils")

local SelectorVisuals = {
	sp_textframe_left = love.graphics.newImage(PATH .. "/images/textframe_left.png"),
	sp_textframe_right = love.graphics.newImage(PATH .. "/images/textframe_right.png"),
	sp_textframe_center = love.graphics.newImage(PATH .. "/images/textframe_center.png"),
	sp_arrow = love.graphics.newImage(PATH .. "/images/selector_arrow.png")
}

SelectorVisuals.textframe_height = SelectorVisuals.sp_textframe_center:getHeight()
SelectorVisuals.textframe_width = SelectorVisuals.sp_textframe_right:getWidth() +
	SelectorVisuals.sp_textframe_center:getWidth() + SelectorVisuals.sp_textframe_left:getWidth()

local function drawTextframe(x, y, scale_x, scale_y)
	love.graphics.draw(SelectorVisuals.sp_textframe_left, x, y, 0, scale_y, scale_y)
	local middle_x = SelectorVisuals.sp_textframe_left:getWidth() * scale_y
	love.graphics.draw(SelectorVisuals.sp_textframe_center, x + middle_x, y, 0, scale_x, scale_y)
	local right_x = middle_x + SelectorVisuals.sp_textframe_center:getWidth() * scale_x
	love.graphics.draw(SelectorVisuals.sp_textframe_right, x + right_x, y, 0, scale_y, scale_y)
end

local ISelector = Inky.defineElement(function(self)
	return function(_, x, y, w, h, mirror)
		local arrow_scale = h / SelectorVisuals.sp_arrow:getHeight()
		if mirror == true then
			love.graphics.draw(SelectorVisuals.sp_arrow, x + w, y, 0, -1 * arrow_scale, arrow_scale)
		else
			love.graphics.draw(SelectorVisuals.sp_arrow, x, y, 0, arrow_scale, arrow_scale)
		end
	end
end)

local ArrowSelector = {
	name = "ArrowSelector"
}

function ArrowSelector:New(scene, x, y, width, height, text_options, default_option)
	if default_option == nil then
		default_option = 1
	end
	local newObj = {
		x = x,
		y = y,
		width = width,
		height = height,
		text_options = text_options,
		options_index = default_option
	}

	newObj.arrow_scale = height / SelectorVisuals.textframe_height
	newObj.arrow_width = SelectorVisuals.sp_arrow:getWidth() * newObj.arrow_scale
	newObj.arrow_height = SelectorVisuals.sp_arrow:getHeight() * newObj.arrow_scale
	_, newObj.arrow_y = Utils.center(width, height, newObj.arrow_width, newObj.arrow_height)
	newObj.arrow_y = newObj.arrow_y + newObj.y

	newObj.left_inky_obj = ISelector(scene)
	newObj.right_inky_obj = ISelector(scene)

	newObj.textframe_x = x + newObj.arrow_width
	newObj.textframe_width = width - newObj.arrow_width * 2
	local frame_ends_w = SelectorVisuals.sp_textframe_left:getWidth() + SelectorVisuals.sp_textframe_right:getWidth()
	newObj.textframe_scale_y = height / SelectorVisuals.textframe_height
	local ends_width = frame_ends_w * newObj.textframe_scale_y
	local middle_target = newObj.textframe_width - ends_width
	newObj.textframe_scale_x = middle_target / SelectorVisuals.sp_textframe_center:getWidth()

	newObj.display_text = love.graphics.newText(UnifontEX, { { 0.9, 0.9, 0.9, 1.0 }, "" })


	self.__index = self
	setmetatable(newObj, self)

	newObj.left_inky_obj:onPointer("release", function(_)
		local idx = (newObj.options_index - 1) % #newObj.text_options
		if idx <= 0 then idx = #newObj.text_options end
		newObj.options_index = idx
	end)
	newObj.right_inky_obj:onPointer("release", function(_)
		local idx = (newObj.options_index + 1) % #newObj.text_options
		if idx <= 0 then idx = #newObj.text_options end
		newObj.options_index = idx
	end)

	return newObj
end

function ArrowSelector:renderText()
	local text_string = tostring(self.text_options[self.options_index])
	self.display_text:set(text_string)

	local textbox_width = self.textframe_width - 20 * 2
	local textbox_height = self.height - self.height * 0.10
	local text_height = self.display_text:getFont():getHeight(text_string)
	local text_width = self.display_text:getFont():getWidth(text_string)
	local text_scale = Utils.scaleText(text_width, text_height, textbox_width, textbox_height)

	local rel_text_x, rel_text_y = Utils.center(textbox_width, textbox_height, text_width * text_scale,
		text_height * text_scale)
	local text_x = rel_text_x + self.textframe_x + (self.textframe_width - textbox_width) / 2
	local textbox_y = (self.height - textbox_height) / 2 + self.y
	local text_y = rel_text_y + textbox_y

	love.graphics.draw(self.display_text, text_x, text_y, 0, text_scale, text_scale)
end

function ArrowSelector:draw()
	drawTextframe(self.textframe_x, self.y, self.textframe_scale_x, self.textframe_scale_y)

	self.left_inky_obj:render(self.x, self.arrow_y, self.arrow_width, self.arrow_height, false)
	local right_x = self.x + self.textframe_width + self.arrow_width
	self.right_inky_obj:render(right_x, self.arrow_y, self.arrow_width, self.arrow_height, true)

	self:renderText()
end

function ArrowSelector:getSelected()
	return self.text_options[self.options_index]
end

return ArrowSelector
