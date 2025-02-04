local Timer = {
	name = "Timer"
}

local font = love.graphics.getFont()

local function leftPad(s, c)

end

---Given a length of time in seconds, convert tha time to a string in HH:MM:SS.ms format
---@param time number
---@param decimal_places number? Default to 1 if time is less than a minute, and 0 otherwise
---@return string
local function secsToClock(time, decimal_places)
	-- hours
	-- floor division by 3600, subtract result * 3600 from time
	local hours = math.floor(time / 3600)
	time = time - (hours * 3600)
	local minutes = math.floor(time / 60)
	time = time - (minutes * 60)
	local ms = time % 1
	local seconds = math.floor(time)

	local h_string = ''
	local m_string = ''
	local s_string = ''
	local ms_string = ''

	if hours > 0 then
		h_string = string.format("%i", hours) .. ':'
		m_string = string.format("%02i", minutes) .. ':'
	elseif minutes > 0 then
		m_string = string.format("%02i", minutes) .. ':'
	end

	if decimal_places == nil then
		if hours == 0 and minutes == 0 then
			s_string = string.format("%02i", seconds)
			ms_string = string.sub(string.format("%.1f", ms), 2, 3)
		else
			s_string = string.format("%02i", seconds)
		end
	elseif decimal_places ~= 0 then
		s_string = string.format("%02i", seconds)
		-- use math.floor for consistency with the hours, minutes, seconds
		ms = math.floor(ms * 10 ^ decimal_places) / 10 ^ decimal_places
		ms_string = tostring(ms)
		ms_string = string.sub(ms_string, 2, 2 + decimal_places)
	else
		s_string = string.format("%02i", seconds)
	end
	return h_string .. m_string .. s_string .. ms_string
end

function Timer:new(x, y, start_time, increment)
	local newObj = {
		x = x,
		y = y,
		-- sprites
		body = love.graphics.newImage("images/timer.png"),
		-- initial values for actual timing
		player_times = { start_time, start_time },
		increment = increment,
	}

	newObj.width = newObj.body:getWidth()
	newObj.height = newObj.body:getHeight()

	newObj.p1_display = love.graphics.newText(font, secsToClock(newObj.player_times[1]))
	newObj.p2_display = love.graphics.newText(font, secsToClock(newObj.player_times[2]))

	self.__index = self

	setmetatable(newObj, self)

	return newObj
end

---Update the timer and return whether or not a player has flagged
---@return boolean # true if the current player has flagged, false otherwise
function Timer:update(delta)
	-- step the timer
	if self.turn ~= nil and (self.turn == 1 or self.turn == 2) then
		self.player_times[self.turn] = self.player_times[self.turn] - delta
		return self.player_times[self.turn] <= 0.0
	end
	return false
end

function Timer:draw()
	-- update text objects
	self.p1_display:set(secsToClock(self.player_times[1]))
	self.p2_display:set(secsToClock(self.player_times[2]))

	love.graphics.draw(self.body, self.x, self.y)
	love.graphics.draw(self.p1_display, self.x + 50, self.y + 130, 0, 3, 3)
	love.graphics.draw(self.p2_display, self.x + 50, self.y + 480, 0, 3, 3)
end

---Starts running the timer, with it being player_id's turn
---@param player_id number
function Timer:start(player_id)
	self.turn = player_id
end

return Timer
