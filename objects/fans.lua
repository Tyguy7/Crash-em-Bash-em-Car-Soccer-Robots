require "math"

require "libs.middleclass"
require "libs.art"

local GameObject = require "objects.gameobject"

local Fans = class("Fans", GameObject)
Fans.static.IMAGE = "fans.png"
Fans.static.FLASH = "flash.png"
Fans.static.CHEERS = {"cheer-01.ogg", "cheer-03.ogg", "kids-cheer-01.ogg"}
Fans.static.X_LOC = 400
Fans.static.Y_LOC = 50
Fans.static.COLOR = {255, 255, 255}

function Fans:initialize(world)
	self.player = player

	self.body = love.physics.newBody(world, self.class.X_LOC, self.class.Y_LOC, 0)
	self.shape = love.physics.newRectangleShape(self.body, 0, 0, 800, 100)
	self.shape:setData("boundary")

	self.image = art(self.class.IMAGE)

	self.color = self.class.COLOR

	self.flash = art(self.class.FLASH)
	self.flashes = {}

	self.cheers = {}
	for i, cheer_filename in ipairs(self.class.CHEERS) do
		table.insert(self.cheers, art(cheer_filename))
	end
end

function Fans:scheduleFlashes(number)
	for i = 1, number do
		local location = {math.random(0, 800), math.random(0, 100),
						  math.random(number)}
		table.insert(self.flashes, location)
	end
end

function Fans:cheer()
	local choice = math.random(#self.cheers)
	self.cheers[choice]:play()
end

function Fans:goalScored()
	self:scheduleFlashes(50)
	self:cheer()
end

function Fans:gameOver()
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
			love.graphics.draw(self.flash, location[1], location[2], 0, 1, 1, 64, 64)
		end
	end
end

return Fans
