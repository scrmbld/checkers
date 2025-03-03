local PATH = (...):gsub('%.init$', '')
local Widgets = {}

UnifontEX = love.graphics.newFont('font/UnifontExMono.ttf', 48)

---@module "widgets.arrowSelector"
Widgets.arrowSelector = require(PATH .. ".arrow_selector")
---@module "widgets.button"
Widgets.button = require(PATH .. ".button")
---@module "widgets.menu"
Widgets.menu = require(PATH .. ".menu")

return Widgets
