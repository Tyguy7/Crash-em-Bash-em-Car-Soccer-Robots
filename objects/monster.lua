require "libs.middleclass"

local Car = require "objects.car"

local Monster = class("Monster", Car)
Monster.static.IMAGE = "truck.png"
Monster.static.WIDTH = 60
Monster.static.HEIGHT = 32
Monster.static.MASS = 15
Monster.static.FORWARD = 210
return Monster
