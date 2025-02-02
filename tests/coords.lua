package.path = "../?.lua;" .. package.path

local lunatest = require("lunatest")
local Coords = require("coords")

function test_constructor()
	local c1 = Coords:new(1, 2)
	lunatest.assert_equal(c1.x, 1)
	lunatest.assert_equal(c1.y, 2)
end

function test_eq()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(2, 2)
	local c3 = Coords:new(1, 3)
	local c4 = Coords:new(1, 2)
	lunatest.assert_false(c1 == c2)
	lunatest.assert_false(c1 == c3)
	lunatest.assert_true(c1 == c4)
end

function test_add()
	-- inputs to Coords.__add
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(2, 2)
	local c3 = Coords:new(-2, 2)

	local s1 = c1 + c2
	local s2 = c2 + c1
	local s3 = c1 + c3
	local s4 = c3 + c1

	-- correct outputs for Coords.__add
	local a1 = Coords:new(3, 4)
	local a2 = Coords:new(3, 4)
	local a3 = Coords:new(-1, 4)
	local a4 = Coords:new(-1, 4)

	lunatest.assert_equal(a1, s1)
	lunatest.assert_equal(a2, s2)
	lunatest.assert_equal(a3, s3)
	lunatest.assert_equal(a4, s4)
end

function test_sub()
	-- inputs to Coords.__add
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(2, 2)
	local c3 = Coords:new(-2, 2)

	local s1 = c1 - c2
	local s2 = c2 - c1
	local s3 = c1 - c3
	local s4 = c3 - c1

	-- correct outputs for Coords.__sub
	local a1 = Coords:new(-1, 0)
	local a2 = Coords:new(1, 0)
	local a3 = Coords:new(3, 0)
	local a4 = Coords:new(-3, 0)

	lunatest.assert_equal(a1, s1)
	lunatest.assert_equal(a2, s2)
	lunatest.assert_equal(a3, s3)
	lunatest.assert_equal(a4, s4)
end

function test_mul()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(-1, -2)
	local c3 = Coords:new(5, 4)

	local s1 = c1 * 2
	local s2 = c1 * -4
	local s3 = c2 * 2
	local s4 = c2 * -4
	local s5 = c3 * 2
	local s6 = c3 * -4

	local a1 = Coords:new(2, 4)
	local a2 = Coords:new(-4, -8)
	local a3 = Coords:new(-2, -4)
	local a4 = Coords:new(4, 8)
	local a5 = Coords:new(10, 8)
	local a6 = Coords:new(-20, -16)

	lunatest.assert_equal(a1, s1)
	lunatest.assert_equal(a2, s2)
	lunatest.assert_equal(a3, s3)
	lunatest.assert_equal(a4, s4)
	lunatest.assert_equal(a5, s5)
	lunatest.assert_equal(a6, s6)
end

function test_div()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(-1, -2)
	local c3 = Coords:new(5, 4)

	local s1 = c1 / 2
	local s2 = c1 / -4
	local s3 = c2 / 2
	local s4 = c2 / -4
	local s5 = c3 / 2
	local s6 = c3 / -4

	local a1 = Coords:new(0.5, 1)
	local a2 = Coords:new(-0.25, -0.5)
	local a3 = Coords:new(-0.5, -1)
	local a4 = Coords:new(0.25, 0.5)
	local a5 = Coords:new(2.5, 2)
	local a6 = Coords:new(-1.25, -1)

	lunatest.assert_equal(a1, s1)
	lunatest.assert_equal(a2, s2)
	lunatest.assert_equal(a3, s3)
	lunatest.assert_equal(a4, s4)
	lunatest.assert_equal(a5, s5)
	lunatest.assert_equal(a6, s6)
end

function test_abs()
	local c1 = Coords:new(1, 2)
	local c2 = Coords:new(-1, 2)
	local c3 = Coords:new(1, -2)
	local c4 = Coords:new(-1, -2)

	local s1 = c1:abs()
	local s2 = c2:abs()
	local s3 = c3:abs()
	local s4 = c4:abs()

	local a1 = Coords:new(1, 2)
	local a2 = Coords:new(1, 2)
	local a3 = Coords:new(1, 2)
	local a4 = Coords:new(1, 2)

	lunatest.assert_equal(a1, s1)
	lunatest.assert_equal(a2, s2)
	lunatest.assert_equal(a3, s3)
	lunatest.assert_equal(a4, s4)
end

lunatest.run()
