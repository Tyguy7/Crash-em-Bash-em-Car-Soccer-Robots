require "math"

require "libs.middleclass"

local GameObject = require "objects.gameobject"

local Fans = class("Fans", GameObject)
Fans.static.IMAGE = "fans.png"
Fans.static.FLASH = "flash.png"
Fans.static.X_LOC = 400
Fans.static.Y_LOC = 50
Fans.static.COLOR = {255, 255, 255}

function Fans:initialize(world)
	self.player = player

	self.body = love.physics.newBody(world, self.class.X_LOC, self.class.Y_LOC, 0)
	self.shape = love.physics.newRectangleShape(self.body, 0, 0, 800, 100)

	self.image = love.graphics.newImage("res/images/"..self.class.IMAGE)

	self.color = self.class.COLOR

	self.flashes = {}
end

function Fans:scheduleFlashes(number)
	for i = 1, number do
		local location = {math.random(0, 800), math.random(0, 100),
						  math.random(number)}
		table.insert(self.flashes, location)
	end
end

function Fans:startGoalFlashes()
	self:scheduleFlashes(50)
end

function Fans:startGameOverFlashes()
	self:scheduleFlashes(1000)
end

function Fans:update()
	local remove = {}
	for i, location in ipairs(self.flashes) do
		location[3] = location[3] - .8
		if location[3] <= 0 then
			table.insert(remove, i)
		end
	end
	for i, remove_index in ipairs(remove) do
		table.remove(self.flashes, remove_index)
	end
end

function Fans:draw()
	Fans.super.draw(self)
	for i, location in ipairs(self.flashes) do
		if location[3] < 2 then
			love.graphics.draw(flash, location[1], location[2], 0, 1, 1, 64, 64)
		end
	end
end

return Fans
