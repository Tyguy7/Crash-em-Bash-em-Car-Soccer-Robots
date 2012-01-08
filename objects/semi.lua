require "libs.middleclass"

local Car = require "objects.car"

local Semi = class("Semi", Car)
Semi.static.IMAGE = "semi.png"
Semi.static.WIDTH = 55
Semi.static.HEIGHT = 42
Semi.static.MASS = 30
Semi.static.FORWARD = 110

Semi.static.ROTATION_INERTIA = 5
Semi.static.ANGULAR_DAMPING = 5

return Semi
