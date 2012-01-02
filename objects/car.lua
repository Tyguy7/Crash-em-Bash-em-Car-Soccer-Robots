require "math"

require "libs.middleclass"

local GameObject = require "objects.gameobject"

local Car = class("Car", GameObject)
Car.static.TURN_TORQUE = 40
Car.static.FORWARD = 160
Car.static.REVERSE = -60

Car.static.MASS = 5
Car.static.ROTATION_INERTIA = 3
Car.static.LINEAR_DAMPING = 1
Car.static.ANGULAR_DAMPING = 3

Car.static.WIDTH = 64
Car.static.HEIGHT = 26

Car.static.IMAGE = "car.png"
Car.static.TIRE_MARK_IMAGE = "tiremark.png"
Car.static.SCREECH = "screech.wav"

Car.static.INFO = {
			        {color={255,0,0}, data="red car",
			          keys={left="a", right="d", up="w", down="s"}},
			        {color={0,0,255}, data="blue car",
			          keys={left="left", right="right", up="up", down="down"}}}
Car.static.STARTS = {[2]={
					    {x=250, y=350, angle=0},
					    {x=550, y=350, angle=math.rad(180)}},
				    }
Car.static.TIRE_MARKS = {{28,-16},{28,16},{-22,16},{-22,-16}}
Car.static.TIRE_MARK_LIFETIME = 200


function Car:initialize(player, no_of_players, world)
	local start = self.class.STARTS[no_of_players][player]
	self.player = player
	self.playernum = no_of_players
	self.body = love.physics.newBody(world, start.x, start.y, self.class.MASS,
									 self.class.ROTATION_INERTIA)
	self.body:setAngle(start.angle)
	self.body:setAngularDamping(self.class.ANGULAR_DAMPING)
	self.body:setLinearDamping(self.class.LINEAR_DAMPING)
	self.shape = love.physics.newRectangleShape(self.body, 0, 0, self.class.WIDTH,
												self.class.HEIGHT)

	local info = self.class.INFO[player]
	self.color = info.color
	self.shape:setData(info.data)
	self.image = love.graphics.newImage("res/images/"..self.class.IMAGE)
	self.tire_mark_image = love.graphics.newImage("res/images/"..self.class.TIRE_MARK_IMAGE)
	self.keys = info.keys
	self.screech = love.audio.newSource("res/sounds/"..self.class.SCREECH, "static")
	self.screech:setLooping(true)
	self.screech:setVolume(0.3)

	self.tire_marks = {}
end

local function normAngle(angle)
	return angle % math.pi*2
end

local function difference(a1, a2)
	a1, a2 = normAngle(a1), normAngle(a2)
	if a1 > a2 then
		a1, a2 = a2, a1
	end
	return (a2 - a1)%math.pi
end

local function shouldScreech(car_body)
	velocity_x, velocity_y = car_body:getLinearVelocity()
	velocity_angle = math.atan2(velocity_y, velocity_x)
	if math.abs(velocity_y) + math.abs(velocity_y) < 60 then
		return nil
	end
	return difference(velocity_angle, car_body:getAngle()) > math.rad(40)
end

function Car:addTireMarks()
	for i, location in ipairs(self.class.TIRE_MARKS) do
		local new_mark = {self.body:getWorldPoint(location[1], location[2])}
		new_mark[3] = self.class.TIRE_MARK_LIFETIME
		table.insert(self.tire_marks, new_mark)
	end
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

	if shouldScreech(self.body) then
		if not self.screeching then
			self.screech:play()
			self.screeching = true
		end
		self:addTireMarks()
	elseif self.screeching then
		self.screech:stop()
		self.screeching = false
	end

	local remove = {}
	for i, mark in ipairs(self.tire_marks) do
		mark[3] = mark[3] - 1
		if mark[3] <= 0 then
			table.insert(remove, i)
		end
	end
	for i, remove_index in ipairs(remove) do
		table.remove(self.tire_marks, remove_index)
	end
end

function Car:draw()
	for i, location in ipairs(self.tire_marks) do
		if location[3] > 60 then
			alpha = 255
		elseif location[3] <= 0 then
			alpha = 0
		else
			alpha = location[3]*255/60
		end
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(self.tire_mark_image, location[1], location[2], 0, 1, 1, 2, 2)
	end
	love.graphics.setColor(255,255,255)

	Car.super.draw(self)
end

return Car
