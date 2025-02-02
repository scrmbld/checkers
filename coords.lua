local Coords = {
	name = 'Coords'
}

---Creates a new coordinate pair. This allows for comparing 2D coordinates.
---@param x number
---@param y number
---@return table
function Coords:new(x, y)
	local newObj = {
		x = x,
		y = y,
	}

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

---Compares a coordinate pair.
---@param c1 table
---@param c2 table
---@return boolean
function Coords.__eq(c1, c2)
	for k, v in pairs(c1) do
		if c2[k] ~= v then
			return false
		end
	end

	return true
end

---Adds a coordinate pair
---@param c1 table
---@param c2 table
---@return table
function Coords.__add(c1, c2)
	return Coords:new(c1.x + c2.x, c1.y + c2.y)
end

function Coords.__sub(c1, c2)
	return Coords:new(c1.x - c2.x, c1.y - c2.y)
end

function Coords.__div(c1, divisor)
	return Coords:new(c1.x / divisor, c1.y / divisor)
end

function Coords.__mul(c1, factor)
	return Coords:new(c1.x * factor, c1.y * factor)
end

---Convert a coordinate pair to string so that we can print it
function Coords.__tostring(s)
	return "(" .. tostring(s.x) .. ", " .. tostring(s.y) .. ")"
end

---Return a new Coords object in which all vector components are the absolute value of the original's
function Coords:abs()
	local x = math.abs(self.x)
	local y = math.abs(self.y)
	return Coords:new(x, y)
end

return Coords
