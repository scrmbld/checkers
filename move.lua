local Coords = require("coords")
local Move = {
	name = "Move"
}

---Creates a new Move, which consists of a starting Coords and a final Coords
function Move:new(start, final)
	local newObj = {
		start = start,
		final = final,
	}

	-- get the direction (assume a perfect diagonal or straight line)
	local difference = final - start
	local x_dir = math.abs(difference.x) / difference.x
	local y_dir = math.abs(difference.y) / difference.y

	newObj.direction = Coords:new(x_dir, y_dir)
	-- also the magnitude
	newObj.magnitude = difference:abs().x

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

---Creates a new Move, which consists of a starting Coords and a final Coords
---@param startx number
---@param starty number
---@param finalx number
---@param finaly number
---@return table
function Move:from_numbers(startx, starty, finalx, finaly)
	local start = Coords:new(startx, starty)
	local final = Coords:new(finalx, finaly)

	return Move:new(start, final)
end

function Move.__tostring(s)
	local result = '[' .. tostring(s.start) .. ', ' .. tostring(s.final) .. ']'
	return result
end

function Move.__eq(m1, m2)
	return m1.start == m2.start and m1.final == m2.final
end

return Move
