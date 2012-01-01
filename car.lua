require "middleclass"
require "math"

local Car = class("Car")

Car.static.TURN_TORQUE = 40
Car.static.FORWARD = 160
Car.static.REVERSE = -60

Car.static.MASS = 5
Car.static.ROTATION_INERTIA = 3
Car.static.LINEAR_DAMPING = 1
Car.static.ANGULAR_DAMPING = 3

Car.static.WIDTH = 64
Car.static.HEIGHT = 26

Car.static.INFO = {
			        {image="red.png", data="red car",
			          keys={left="a", right="d", up="w", down="s"}},
			        {image="blue.png", data="blue car",
			          keys={left="left", right="right", up="up", down="down"}}}
Car.static.STARTS = {[2]={
					    {x=250, y=350, angle=0},
					    {x=550, y=350, angle=math.rad(180)}},
				    }


function Car:initialize(player, no_of_players, world)
	local start = self.class.STARTS[no_of_players][player]

	self.body = love.physics.newBody(world, start.x, start.y, self.class.MASS,
									 self.class.ROTATION_INERTIA)
	self.body:setAngle(start.angle)
	self.body:setAngularDamping(self.class.ANGULAR_DAMPING)
	self.body:setLinearDamping(self.class.LINEAR_DAMPING)
	self.shape = love.physics.newRectangleShape(self.body, 0, 0, self.class.WIDTH,
												self.class.HEIGHT)

	local info = self.class.INFO
	self.shape:setData(info[player].data)
	self.image = love.graphics.newImage("images/"..info[player].image)
	self.keys = info[player].keys
end

function Car:update()
	if love.keyboard.isDown(self.keys.left) then
        self.body:applyTorque(-self.class.TURN_TORQUE)
    end
    if love.keyboard.isDown(self.keys.right) then
        self.body:applyTorque(self.class.TURN_TORQUE)
    end
    if love.keyboard.isDown(self.keys.up) then
        self.body:applyForce(self.body:getWorldVector(self.class.FORWARD,0))
    end
    if love.keyboard.isDown(self.keys.down) then
        self.body:applyForce(self.body:getWorldVector(self.class.REVERSE,0))
    end
end

function Car:draw()
	local offset = self.class.WIDTH/2
	local world_x, world_y = self.body:getWorldPoint(0,0)
	love.graphics.draw(self.image, world_x, world_y, self.body:getAngle(), 1, 1,
					   offset, offset)
end

return Car
