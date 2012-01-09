require "math"

local max = math.max
local min = math.min

function linearAnimation(startX, stopX, startY, stopY)
	local slope = (stopY - startY)/(stopX - startX)
	local offset = startY - slope*startX
	local function _animfunc(x)
		x = math.max(startX, math.min(stopX, x))
		return slope*x + offset
	end
	return _animfunc
end
