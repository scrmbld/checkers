local function centerText(parent_w, parent_h, child_w, child_h)
	local new_x = (parent_w - child_w * 1.05) / 2
	local new_y = (parent_h - child_h * 1.2) / 2
	return new_x, new_y
end

local function center(parent_w, parent_h, child_w, child_h)
	local new_x = (parent_w - child_w) / 2
	local new_y = (parent_h - child_h) / 2
	return new_x, new_y
end

---Compute the scaling factor to scale text such that it fits into a textbox. Maximum scale factor of 1
---@param text_width number the width of the unscaled text
---@param text_height number the height of the unscaled text
---@param textbox_width number the width of the textbox
---@param textbox_height number the height of the textbox
---@return _ number the maximum scale <= 1 that the text needs to have to fit in the box in both dimensions
local function scaleText(text_width, text_height, textbox_width, textbox_height)
	local text_scale = 1
	if text_width > textbox_width then
		text_scale = textbox_width / text_width
		-- only actually use the smallest scale, and apply it to both dimensions to preserve the shape of the text
	end
	local y_scale = textbox_height / text_height
	if y_scale < text_scale then
		text_scale = y_scale
	end

	return text_scale
end

local Utils = {
	centerText = centerText,
	center = center,
	scaleText = scaleText,
}

return Utils
