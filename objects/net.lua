require "math"

require "libs.middleclass"

local GameObject = require "objects.gameobject"

local Net = class("Net", GameObject)
Net.static.IMAGE = "net.png"
Net.static.PLAYER_INFO = {
					{x=75, y=350, angle=0, tag="red net",
					  color = {200,100,100}},
					{x=725, y=350, angle=math.pi, tag="blue net",
					  color={100,100,200}}
	              }

function Net:initialize(player, world)
	self.player = player

	local info = self.class.PLAYER_INFO[player]
	self.body = love.physics.newBody(world, info.x, info.y, 0, 0)
	self.body:setAngle(info.angle)

	local left_side = {-24,-46, 23,-50, 23,-44, -20,-43}
	local back_side = {-24,-46, -19,-43, -19,42, -24,46}
	local right_side = {-20,42, 23,47, 23,50, -24,46}
	self.sides = {}
	for i, side_points in ipairs{left_side, back_side, right_side} do
		local side = love.physics.newPolygonShape(self.body, unpack(side_points))
		side:setData("net_boundaries")
		table.insert(self.sides, side)
	end

	local inside = {-20,43, 23,-44, 23,47, -20,42}
	self.inside = love.physics.newPolygonShape(self.body, unpack(inside))
	self.inside:setSensor(true)
	self.inside:setData(info.tag)

	self.image = love.graphics.newImage("images/"..self.class.IMAGE)

	self.color = info.color
end

return Net
