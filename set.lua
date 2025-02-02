local Set = {
	name = "Set"
}

function Set:new(list)
	local newObj = {}
	for _, l in ipairs(list) do
		newObj[l] = true
	end

	self.__index = self
	setmetatable(newObj, self)

	return newObj
end

function Set:append(v)
	self[v] = true
end

function Set:remove(v)
	self[v] = nil
end

function Set.__tostring(s)
	local result = ""
	for i, v in pairs(s) do
		if v then
			result = result .. tostring(i) .. ", "
		end
	end

	return result
end

return Set
