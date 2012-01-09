require "math"
require "table"

require "libs.art"
require "libs.middleclass"
require "libs.interpolation"
local Soundtrack = require "libs.soundtrack"

local Battle = require "states.battle"
local Car = require "objects.car"
local Monster = require "objects.monster"
local Semi = require "objects.semi"

local PlayerPane = class("PlayerPane")

--function PlayerPane:initialize

local MainMenu = class("MainMenu")

MainMenu.static.PICKS = {Car, Monster, Semi}
MainMenu.static.PANE_COLORS = {{255,0,0}, {0,0,255}, {234,97,216}, {97,226,234}}

function MainMenu:startGame()
	self.fadingOut = true
	self.fadeoutOpacity = 0
	self.music:fadeOut(30)
	self.car_picks = {}
	for i, pane in ipairs(self.panes) do
		local insert = nil
		if pane.enabled then
			insert = self.class.PICKS[pane.pick]
		end
		table.insert(self.car_picks, insert)
	end
end

function MainMenu:updatePane(pane_no)
	local pane = self.panes[pane_no]
	pane.object = self.class.PICKS[pane.pick](pane_no, 4, {world=self.world})
	pane.object.body:setPosition(pane_no*200 - 100, 200)
	pane.object.body:setAngle(0)
	pane.text = self.class.PICKS[pane.pick].name
end

function MainMenu:load()
	love.graphics.setBackgroundColor(0, 0, 0)

	self.title = art("title.png")

	self.music = Soundtrack{"title.ogg", "w_a_r_by_awesome.xm",
							"aceman_-_my_first_console.xm"}
	self.music:play()

	self.world = love.physics.newWorld(0, 0, 800, 600)

	self.panes = {{pick=1, enabled=true},
				  {pick=1, enabled=true},
				  {pick=1, enabled=true},
				  {pick=1, enabled=true}}
	for i=1,#self.panes do
		self:updatePane(i)
	end

	self.title_opacity_func = linearAnimation(0, 3.5, 0, 255)
	self.title_y_func = linearAnimation(3.8, 4.0, 236, -15)
	self.pane_opacity_func = linearAnimation(4.7, 5.3, 0, 255)
	self.counter = 0

	love.graphics.setFont(love.graphics.newFont(30))

	return true
end

function MainMenu:keypressed(key)
	local number = tonumber(key)
	if number and number >= 1 and number <= 4 then
		self.panes[number].enabled = not self.panes[number].enabled
	elseif key == "return" then
		self:startGame()
	end
end

function MainMenu:joystickpressed(joystick, button)
	if button == 1 then
		local new_pick = self.panes[joystick+1].pick + 1
		if new_pick > #self.class.PICKS then
			new_pick = 1
		end
		self.panes[joystick+1].pick = new_pick
		self:updatePane(joystick+1)
	elseif button == 3 then
		local new_pick = self.panes[joystick+1].pick - 1
		if new_pick <= 0 then
			new_pick = #self.class.PICKS
		end
		self.panes[joystick+1].pick = new_pick
		self:updatePane(joystick+1)
	end
end

function MainMenu:update(dt)
	self.music:update(dt)
	self.counter = self.counter + dt

	self.title_y = self.title_y_func(self.counter)

	if self.fadingOut then
		self.fadeoutOpacity = self.fadeoutOpacity + 8 * dt * 60
		self.fadeoutOpacity = math.min(255, self.fadeoutOpacity)
		if self.fadeoutOpacity >= 255 then
			local battle_state = Battle(4, self.car_picks)
			battle_state:load()
			return battle_state
		end
	end

	for i, pane in ipairs(self.panes) do
		pane.object.body:setAngle(self.counter * 2)
	end

	return self
end

function MainMenu:draw()
	love.graphics.clear()

	--draw title
	local opacity = self.title_opacity_func(self.counter)
	love.graphics.setColor(255, 255, 255, opacity)
	love.graphics.draw(self.title, 144, self.title_y)

	--draw panes
	local pane_opacity = self.pane_opacity_func(self.counter)
	for i, pane in ipairs(self.panes) do
		local r, g, b = unpack(self.class.PANE_COLORS[i])
		if not pane.enabled then
			r, g, b = 64 + r/7, 64 + g/7, 64 + b/7
		end
		love.graphics.setColor(r, g, b, pane_opacity)
		love.graphics.rectangle("fill", (i-1)*200, 100, 200, 600)
		love.graphics.setColor(156, 156, 156, pane_opacity)
		love.graphics.rectangle("fill", (i-1)*200 + 50, 150, 100, 100)

		pane.object.color[4] = pane_opacity
		pane.object:draw()

		love.graphics.setColor(255, 255, 255, pane_opacity)
		love.graphics.printf(pane.text, (i-1)*200, 300, 200, "center")
	end

	if self.fadingOut then
		love.graphics.setColor(0, 0, 0, self.fadeoutOpacity)
		love.graphics.rectangle("fill", 0, 0, 800, 600)
	end
end

return MainMenu
