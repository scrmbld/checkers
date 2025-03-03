-- globals that are related to settings
BaseResX = 2560
BaseResY = 1440

local Resolution = {
	name = "Resolution"
}

function Resolution:New(x, y)
	local newObj = {
		x = x,
		y = y,
	}

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

function Resolution.__tostring(self)
	return tostring(self.x) .. "x" .. tostring(self.y)
end

-- Stores a comprehensive set of settings for the game
local Settings = {
	name = "Setttings",
}

local function computeScaleFactor(resX, resY)
	local scaleFactor = resX / BaseResX
	if resY / BaseResY < scaleFactor then
		scaleFactor = resY / BaseResY
	end

	return scaleFactor
end

-- Creates a new settings object
function Settings:New()
	local newObj = {
		fullscreen = false,
		allowed_resolutions = {
			Resolution:New(1280, 720),
			Resolution:New(1920, 1080),
			Resolution:New(2560, 1440),
			Resolution:New(3840, 2160),
		},
		current_res_index = 1,
	}

	local res = newObj.allowed_resolutions[1]
	newObj.scaleFactor = computeScaleFactor(res.x, res.y)

	self.__index = self
	setmetatable(newObj, self)

	newObj.previous_values = {
		fullscreen = newObj.fullscreen,
		current_res_index = newObj.current_res_index,
	}

	return newObj
end

---set the resolution in the settings table to width x height.
---@param index number The index in Settings.allowed_resolutions of the new resolution.
function Settings:SetRes(index)
	self.current_res_index = index

	self.scaleFactor = computeScaleFactor(self.resX, self.resY)
end

---set the fullscreen field in the settings table to fullscreen
---@param fullscreen boolean
function Settings:SetFullscreen(fullscreen)
	self.fullscreen = fullscreen
end

function Settings:CurrentResolution()
	return self.allowed_resolutions[self.current_res_index]
end

-- applies the settings in the settings object
function Settings:Apply()
	local res = self:CurrentResolution()
	self.scaleFactor = computeScaleFactor(res.x, res.y)
	love.window.setMode(res.x, res.y, { fullscreen = self.fullscreen })
end

function Settings:Revert()
	self.current_res_index = self.previous_values.current_res_index
	self.fullscreen = self.previous_values.fullscreen
end

return Settings
