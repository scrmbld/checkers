local Timer = {
	name = "Timer"
}

local font = UnifontEX

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
		occluder = love.graphics.newImage("images/timer_occluder.png"),
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
		if self.player_times[self.turn] <= 0.0 then
			self.player_times[self.turn] = 0.0
			return true
		end
	end
	return false
end

function Timer:draw()
	-- update text objects
	self.p1_display:set(secsToClock(self.player_times[1]))
	self.p2_display:set(secsToClock(self.player_times[2]))

	love.graphics.draw(self.body, self.x, self.y)
	love.graphics.draw(self.p1_display, self.x + 70, self.y + 110)
	love.graphics.draw(self.p2_display, self.x + 70, self.y + 460)

	if self.turn == nil then
		love.graphics.draw(self.occluder, self.x + self.width * (17 / 32), self.y + self.height * (28 / 64))
	elseif self.turn == 1 then
		love.graphics.draw(self.occluder, self.x + self.width * (17 / 32), self.y + self.height * (28 / 64))
	elseif self.turn == 2 then
		love.graphics.draw(self.occluder, self.x + self.width * (6 / 32), self.y + self.height * (28 / 64))
	end
end

---Starts running the timer, with it being player_id's turn.
---@param player_id number
---@param increment number? Whether or not to apply the increment to the other player's clock. Default true.
function Timer:start(player_id, increment)
	assert(player_id ~= nil)

	if increment ~= false then
		if player_id == 1 then
			self.player_times[2] = self.player_times[2] + self.increment
		else
			self.player_times[1] = self.player_times[1] + self.increment
		end
	end

	self.turn = player_id
end

---Pause the timer. To unpause, call Timer:start and pass in a player id
function Timer:stop()
	self.turn = nil
end

return Timer
