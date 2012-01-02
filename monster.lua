local Car = require "car"

local Monster = class("Monster", Car)
Monster.static.IMAGE = "truck.png"
Monster.static.HEIGHT = 32
Monster.static.MASS = 15
Monster.static.FORWARD = 210
return Monster
