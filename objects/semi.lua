require "libs.middleclass"

local Car = require "objects.car"

local Semi = class("Semi", Car)
Semi.static.IMAGE = "semi.png"
Semi.static.WIDTH = 55
Semi.static.HEIGHT = 42
Semi.static.MASS = 40
Semi.static.FORWARD = 175
Semi.static.REVERSE = -40
Semi.static.TIRE_MARKS = {{21,-20},{21,20},{-22,20},{-22,-20},{-9,20},{-9,-20}}

Semi.static.ROTATION_INERTIA = 5
Semi.static.ANGULAR_DAMPING = 5

return Semi
