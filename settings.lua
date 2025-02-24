-- globals that are related to settings
BaseResX = 2560
BaseResY = 1440

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
		name = "Setttings",
		resX = 1280,
		resY = 720,
		fullscreen = false
	}

	newObj.scaleFactor = computeScaleFactor(newObj.resX, newObj.resY)

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

-- applies the settings in the settings object
function Settings:Apply()
	love.window.setMode(self.resX, self.resY, { fullscreen = self.fullscreen })
end

---set the resolution in the settings table to width x height
---@param width number
---@param height number
function Settings:SetRes(width, height)
	self.resX = width
	self.resY = height

	self.scaleFactor = computeScaleFactor(self.resX, self.resY)
end

---set the fullscreen field in the settings table to fullscreen
---@param fullscreen boolean
function Settings:SetFullscreen(fullscreen)
	self.fullscreen = fullscreen
end

-- returns an array of allowed resolutions (this is not enforced)
function Settings:AllowedResolutions()
	local allowedRes = {
		{ x = 3840, y = 2160 },
		{ x = 2560, y = 1440 },
		{ x = 1920, y = 1080 },
		{ x = 1280, y = 720 },
	}

	return allowedRes
end

return Settings
