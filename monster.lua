local Car = require "car"

local Monster = class("Monster", Car)
Monster.static.IMAGE = "truck.png"
Monster.static.HEIGHT = 32
return Monster
