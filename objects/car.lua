require "math"

require "libs.middleclass"
require "libs.art"
require "libs.deepcopy"

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
Car.static.SCREECH = "screech.ogg"

Car.static.INFO = {
			        {color={255,0,0}, data="car",
			          keys={left="a", right="d", up="w", down="s"}},
			        {color={0,0,255}, data="car",
			          keys={left="left", right="right", up="up", down="down"}},
					{color={234,97,216}, data="car",
			          keys={left="g", right="j", up="y", down="h"}},
			        {color={97,226,234}, data="car",
			          keys={left="l", right="'", up="p", down=";"}}}
Car.static.STARTS = {[2]={
					    {x=250, y=350, angle=0},
					    {x=550, y=350, angle=math.rad(180)}},
					 [4]={
					    {x=250, y=250, angle=math.rad(35)},
					    {x=550, y=250, angle=math.rad(145)},
						{x=250, y=450, angle=math.rad(-35)},
					    {x=550, y=450, angle=math.rad(-145)}},
				    }
Car.static.TIRE_MARKS = {{28,-16},{28,16},{-22,16},{-22,-16}}
Car.static.TIRE_MARK_LIFETIME = 200


function Car:initialize(player, no_of_players, state)
	self.gameState = state

	local start = self.class.STARTS[no_of_players][player]
	self.player = player
	self.playernum = no_of_players
	self.body = love.physics.newBody(state.world, start.x, start.y, self.class.MASS,
									 self.class.ROTATION_INERTIA)
	self.body:setAngle(start.angle)
	self.body:setAngularDamping(self.class.ANGULAR_DAMPING)
	self.body:setLinearDamping(self.class.LINEAR_DAMPING)
	self.shape = love.physics.newRectangleShape(self.body, 0, 0, self.class.WIDTH,
												self.class.HEIGHT)

	local info = self.class.INFO[player]
	self.color = deepcopy(info.color)
	self.shape:setData(info.data)
	self.image = art(self.class.IMAGE)
	self.tire_mark_image = art(self.class.TIRE_MARK_IMAGE)
	self.keys = info.keys
	self.screech = art(self.class.SCREECH)
	self.screech:setLooping(true)
	self.screech:setVolume(0.3)
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
		local x, y = self.body:getWorldPoint(location[1], location[2])
		self.gameState:addTireMark(x, y, self.class.TIRE_MARK_LIFETIME,
							   self.tire_mark_image)
	end
end

function Car:update()
	local direction = love.joystick.getHat(self.player-1, 0)
	local left = {l=true, ld=true, lu=true}
	local right = {r=true, rd=true, ru=true}
	local up = {u=true, ru=true, lu=true}
	local down = {d=true, ld=true, rd=true}

	if left[direction] then
		self.body:applyTorque(-self.class.TURN_TORQUE)
	end
	if right[direction] then
		self.body:applyTorque(self.class.TURN_TORQUE)
	end
	if up[direction] then
		self.body:applyForce(self.body:getWorldVector(self.class.FORWARD,0))
	end
	if down[direction] then
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
end

return Car
