package.path = "../?.lua;" .. package.path

local lunatest = require("lunatest")
local Move = require("move")
local Coords = require("coords")

function test_constructor()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(2, 3)
	local c3 = Coords:new(4, 4)
	local c4 = Coords:new(6, 2)

	local m1 = Move:new(c1, c2)
	local m2 = Move:new(c2, c1)
	local m3 = Move:new(c3, c4)
	local m4 = Move:new(c4, c3)

	-- m1 tests
	lunatest.assert_equal(c1, m1.start)
	lunatest.assert_equal(c2, m1.final)
	lunatest.assert_equal(Coords:new(1, 1), m1.direction)
	lunatest.assert_equal(1, m1.magnitude)

	-- m2 tests
	lunatest.assert_equal(c2, m2.start)
	lunatest.assert_equal(c1, m2.final)
	lunatest.assert_equal(Coords:new(-1, -1), m2.direction)
	lunatest.assert_equal(1, m1.magnitude)

	-- m3 tests
	lunatest.assert_equal(c3, m3.start)
	lunatest.assert_equal(c4, m3.final)
	lunatest.assert_equal(Coords:new(1, -1), m3.direction)
	lunatest.assert_equal(2, m3.magnitude)

	-- m4 tests
	lunatest.assert_equal(c4, m4.start)
	lunatest.assert_equal(c3, m4.final)
	lunatest.assert_equal(Coords:new(-1, 1), m4.direction)
	lunatest.assert_equal(2, m4.magnitude)
end

function test_fromNumbers()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(2, 3)

	local m1 = Move:from_numbers(1, 2, 2, 3)
	local m2 = Move:from_numbers(2, 3, 1, 2)

	lunatest.assert_equal(c1, m1.start)
	lunatest.assert_equal(c2, m1.final)
	lunatest.assert_equal(Coords:new(1, 1), m1.direction)
	lunatest.assert_equal(1, m1.magnitude)

	lunatest.assert_equal(c2, m2.start)
	lunatest.assert_equal(c1, m2.final)
	lunatest.assert_equal(Coords:new(-1, -1), m2.direction)
	lunatest.assert_equal(1, m1.magnitude)
end

lunatest.run()
