local Car = require "car"

local Monster = class("Monster", Car)
Monster.static.INFO[2].image = "bluetruck.png"
Monster.static.HEIGHT = 32
return Monster


