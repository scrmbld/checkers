package.path = "../?.lua;" .. package.path

local lunatest = require("lunatest")
local Move = require("move")
local Coords = require("coords")
local Board = require("board")

local b1 = Board:new(0, 0)
