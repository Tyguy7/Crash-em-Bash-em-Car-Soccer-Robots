require "middleclass"
require "math"

local Net = class("Net")
Net.static.WIDTH = 50
Net.static.HEIGHT = 100
Net.static.IMAGE = "net.png"
Net.static.POSITION = {
		    {x=75, y=350, angle=0, net="red net"},
		    {x=725, y=350, angle=math.rad(180), net="blue net"}
	              }
Net.static.COLORS = {
		{200,100,100},
		{200,100,100}
		}

function Net:initialize(player, no_of_players, world)
	local start = self.class.POSITION[player]
	self.player = player
	self.playernum = no_of_players
	self.body = love.physics.newBody(world, start.x, start.y, self.class.MASS,
									 self.class.ROTATION_INERTIA)
	polyPoints = {1,4,48,0,48,6,5,7,5,92,48,97,48,100,1,96}
	self.shapes = {}
	self.shapes[1] = love.physics.newPolygonShape(self.body, -24,-46,23,-50,23,-44,-20,-43)
	self.shapes[2] = love.physics.newPolygonShape(self.body, -24,-46,-19,-43,-19,42,-24,46)
	self.shapes[3] = love.physics.newPolygonShape(self.body, -20,42,23,47,23,50,-24,46)
	self.shape = love.physics.newPolygonShape(self.body, -20,43,23,-44,23,47,-20,42)
	self.body:setAngle(start.angle)

	self.color = self.class.COLORS[player]
	for i, shape in ipairs(self.shapes) do
	shape:setData("netboundaries")
	end
	self.shape:setData(self.class.POSITION[player].net)
	self.shape:setSensor(true)
	self.image = love.graphics.newImage("images/"..self.class.IMAGE)
end

function Net:draw()
	local oldColor = {love.graphics.getColor()}
        love.graphics.setColor(unpack(self.color))

	local x_offset = self.class.WIDTH/2
	local y_offset = self.class.HEIGHT/2
	local world_x, world_y = self.body:getWorldPoint(0,0)

	love.graphics.draw(self.image, world_x, world_y, self.body:getAngle(), 1, 1, x_offset, y_offset)
	love.graphics.setColor(unpack(oldColor))
end
return Net
