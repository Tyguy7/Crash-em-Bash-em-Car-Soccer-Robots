require "libs.middleclass"

local Controls = class("Controls")
function Controls:initialize()
	self.controls = {}
end

function Controls:setControl(name, device, button)
	self.controls[name] = {}
end

function Controls:update()

end

function Controls:control(name)

end
