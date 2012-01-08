require "math"

require "libs.middleclass"
require "libs.art"

local GameObject = require "objects.gameobject"

local Field = class("Field", GameObject)
Field.static.IMAGE = "field.png"
Field.static.X_LOC = 0
Field.static.Y_LOC = 0
Field.static.COLOR = {1000, 1000, 1000}


function Field:initialize(world)
	self.body = love.physics.newBody(world, 400, 350, 0)
	self.image = art(self.class.IMAGE)
        self.color = self.class.COLOR

end

function Field:draw()
	Field.super.draw(self)
end

return Field
