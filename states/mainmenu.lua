require "math"

require "libs.art"
local Soundtrack = require "libs.soundtrack"

local Battle = require "states.battle"

local state = {}

local function startGame(num_players)
	state.fadingOut = true
	state.fadeoutOpacity = 0
	state.music:fadeOut(30)
	assert(num_players)
	state.num_players = num_players
end

local function goToSetup(data)

end

function state:load()
	love.graphics.setBackgroundColor(0, 0, 0)
	self.title = art("title.png")
	self.music = Soundtrack{"title.ogg", "w_a_r_by_awesome.xm",
							"aceman_-_my_first_console.xm"}

	self.selection = 1
	self.choices = {{"2-Player", startGame, 2},
					{"4-Player", startGame, 4},
					{"Setup", goToSetup, nil}
					}

	self.fadeInLength = 3.5
	self.counter = 0

	self.title_y = 44
	self.selection_opacity = 0

	self.selection_min_y = 250
	self.selection_max_y = 500

	love.graphics.setFont(love.graphics.newFont(30))

	self.music:play()
	return true
end

function state:keypressed(key)
	if key == "up" then
		self.selection = self.selection - 1
	elseif key == "down" then
		self.selection = self.selection + 1
	end
	if self.selection > #self.choices then
		self.selection = 1
	elseif self.selection < 1 then
		self.selection = #self.choices
	end

	if key == "return" or key == " " then
		local event = self.choices[self.selection][2]
		local data = self.choices[self.selection][3]
		event(data)
	end
end

function state:update(dt)
	self.music:update(dt)
	self.counter = self.counter + dt

	local y_pos_counter = math.min(math.max(3.8, self.counter), 4.0)
	self.title_y = y_pos_counter*-800 + 3084

	local sel_opacity_counter =  math.min(math.max(5.33, self.counter-.5), 5.83)
	self.selection_opacity = sel_opacity_counter*510 - 2718.3

	if self.fadingOut then
		self.fadeoutOpacity = self.fadeoutOpacity + 8 * dt * 60
		self.fadeoutOpacity = math.min(255, self.fadeoutOpacity)
		if self.fadeoutOpacity >= 255 then
			local battle_state = Battle(self.num_players)
			battle_state:load()
			return battle_state
		end
	end

	return self
end

function state:draw()
	love.graphics.clear()

	--draw title
	local opacity = math.min(1, self.counter/self.fadeInLength)*255
	love.graphics.setColor(255, 255, 255, opacity)
	love.graphics.draw(self.title, 144, self.title_y)

	--draw selections
	local choice_y_factor = (self.selection_max_y - self.selection_min_y)/(#self.choices - 1)
	for i, choice in ipairs(self.choices) do
		if i == self.selection then
			love.graphics.setColor(255, 100, 100, self.selection_opacity)
		else
			love.graphics.setColor(255, 255, 255, self.selection_opacity)
		end
		local y = self.selection_min_y + ((i-1)*choice_y_factor)
		love.graphics.printf(choice[1], 0, y, 800, "center")
	end

	if self.fadingOut then
		love.graphics.setColor(0, 0, 0, self.fadeoutOpacity)
		love.graphics.rectangle("fill", 0, 0, 800, 600)
	end
end

return state
