require "libs.middleclass"

local GameObject = require "objects.gameobject"

local Ball = class("Ball", GameObject)

Ball.static.IMAGE = "ball.png"
Ball.static.COLOR = {255, 255, 255}

Ball.static.RADIUS = 10
Ball.static.MASS = 1
Ball.static.ROTATION_INERTIA = 1
Ball.static.ANGULAR_DAMPING = 0.4
Ball.static.LINEAR_DAMPING = 0.4
Ball.static.TAG = "ball"

function Ball:initialize(world)
	self.image = love.graphics.newImage("res/images/"..self.class.IMAGE)
	self.color = {unpack(self.class.COLOR)}
	self.body = love.physics.newBody(world, 400, 350, self.class.MASS,
									 self.class.ROTATION_INERTIA)
	self.body:setAngularDamping(self.class.ANGULAR_DAMPING)
	self.body:setLinearDamping(self.class.LINEAR_DAMPING)
	self.shape = love.physics.newCircleShape(self.body, 0, 0, self.class.RADIUS)
	self.shape:setData("ball")
end

function Ball:reset()
	self.body:setPosition(400, 350)
	self.body:setLinearVelocity(0, 0)
end

function Ball:update()
	local x, y = self.body:getPosition()
	local distance_x, distance_y = 400 - x, 350 - y
	self.body:applyForce(distance_x/160, distance_y/160)
end

return Ball
