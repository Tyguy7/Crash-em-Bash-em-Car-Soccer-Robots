require "middleclass"

GameObject = class("GameObject")
function GameObject:draw()
	local oldColor = {love.graphics.getColor()}
	love.graphics.setColor(unpack(self.color))

	local x_offset = self.image:getWidth()/2
	local y_offset = self.image:getHeight()/2
	local world_x, world_y = self.body:getWorldPoint(0,0)

	love.graphics.draw(self.image, world_x, world_y, self.body:getAngle(), 1, 1,
					   x_offset, y_offset)

	love.graphics.setColor(unpack(oldColor))
end

return GameObject


