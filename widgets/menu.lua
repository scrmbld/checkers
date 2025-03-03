local PATH = (...):gsub('%.menu$', '')

local Inky = require(PATH .. ".inky")
local Button = require(PATH .. ".button")
local ArrowSelector = require(PATH .. ".arrow_selector")
local Utils = require(PATH .. ".utils")

local MenuVisuals = {
	sp_background = love.graphics.newImage(PATH .. "/images/dark_menu.png"),
}

MenuVisuals.base_height = MenuVisuals.sp_background:getHeight()
MenuVisuals.base_width = MenuVisuals.sp_background:getWidth()


local Menu = {
	name = "Menu"
}

---Create a new menu
---@param scene Inky.Scene
---@param text string The "title" of the menu
---@param x number
---@param y number
---@param scale number The scaling factor which will be applied to the menu
---@param buttons_params table An array containing tables which define each button in the menu. Legal types are "button" and "arrowSelector"
function Menu:New(scene, text, x, y, scale, buttons_params)
	local newObj = {
		text = text,
		x = x,
		y = y,
		scale = scale,
	}

	newObj.width = MenuVisuals.base_width * scale
	newObj.height = MenuVisuals.base_height * scale

	-- banner text
	newObj.display_text = love.graphics.newText(UnifontEX, { { 0.9, 0.9, 0.9, 1.0 }, newObj.text })
	newObj.text_width, newObj.text_height = newObj.display_text:getDimensions()
	-- determining the proper scale for the text
	newObj.text_scale = 1
	local text_box_width = (MenuVisuals.base_width - 30 * 2) * scale
	local text_box_height = 100 * scale
	if newObj.text_width > text_box_width then
		newObj.text_scale = text_box_width / newObj.text_width
		-- only actually use the smallest scale, and apply it to both dimensions to preserve the shape of the text
		local y_scale = text_box_height
		if y_scale < newObj.text_scale then
			newObj.text_scale = y_scale
		end
	end
	-- determine relative position of the text (we want it to be centered)
	newObj.text_x, _ = Utils.centerText(text_box_width, text_box_height, newObj.text_width * newObj.text_scale,
		newObj.text_height * newObj.text_scale)
	newObj.text_x = newObj.text_x + 30 -- account for "textbox" padding
	newObj.text_y = 20              -- a fixed value


	local allowed_types = {
		["button"] = true,
		["arrowSelector"] = true,
	}
	local buttons_array = {}
	if buttons_params ~= nil then
		print("making buttons...")
		for i, v in ipairs(buttons_params) do
			local button_x = x + 20
			local button_y = y + 100 * (i - 1) + 120
			if not allowed_types[v.type] then
				error("Unrecognized button type")
			end

			if v.type == "button" then
				local b = Button:New(scene, v.text, button_x, button_y, 280 * scale, 80 * scale, v.onClick)
				table.insert(buttons_array, b)
			elseif v.type == "arrowSelector" then
				if v.start_index == nil then v.start_index = 1 end
				local b = ArrowSelector:New(scene, button_x, button_y, 280 * scale, 80 * scale, v.options, v.start_index)
				table.insert(buttons_array, b)
			end
		end
	end

	newObj.buttons = buttons_array

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

---Draw a menu, calling render on all its interan inky elements.
function Menu:draw()
	-- background
	local bg_scale_x = self.width / MenuVisuals.base_width
	local bg_scale_y = self.height / MenuVisuals.base_height
	love.graphics.draw(MenuVisuals.sp_background, self.x, self.y, 0, bg_scale_x, bg_scale_y)

	love.graphics.draw(self.display_text, self.x + self.text_x, self.y + self.text_y, 0, self.text_scale, self
		.text_scale)
	if self.buttons ~= nil then
		for _, v in ipairs(self.buttons) do
			v:draw()
		end
	end
end

return Menu
