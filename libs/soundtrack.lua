require "libs.middleclass"
require "libs.art"

local Soundtrack = class("Soundtrack")

function Soundtrack:initialize(source_names)
	self.num_sources = #source_names
	self.sources = {}
	self.source = 1
	for i, source_name in ipairs(source_names) do
		table.insert(self.sources, art(source_name))
	end
	self.stopped = true
end

function Soundtrack:play()
	self.sources[self.source]:setVolume(1)
	self.sources[self.source]:play()
	self.stopped = false
end

function Soundtrack:stop()
	self.sources[self.source]:pause()
	self.stopped = true
end

function Soundtrack:update()
	if self.sources[self.source]:isStopped() and not self.stopped then
		self.source = self.source + 1
		if self.source > self.num_sources then
			self.source = 1
		end
		self:play()
	end
	if self.fading then
		self.fadeCounter = self.fadeCounter - 1
		self.sources[self.source]:setVolume(self.fadeCounter/self.fadeLength)
		if self.fadeCounter <= 0 then
			self:stop()
			self.fading = false
		end
	end
end

function Soundtrack:fadeOut(fadeLength)
	if not self.stopped then
		self.fadeLength = fadeLength
		self.fading = true
		self.fadeCounter = fadeLength
	end
end

return Soundtrack
