local MainMenu = require "states.mainmenu"

local state = nil

local function cleanExit()
	logging:close()
	love.filesystem.remove("logfile.txt")
	love.event.push("q")
end

function love.load()
	love.graphics.setMode(800, 600, true)
	love.graphics.setCaption("Crash 'Em Bash 'Em Car Soccer Robots")

	love.filesystem.setIdentity("Crash 'Em Bash 'Em Car Soccer Robots")

	logging = love.filesystem.newFile("logfile.txt")
	logging:open("a")

	state = MainMenu()
	while not state:load() do end
end

function love.draw()
	state:draw()
end

function love.update(dt)
	state = state:update(dt)
	if state == nil then
		cleanExit()
	end
end

function love.keypressed(key)
	if key == "escape" then
		cleanExit()
	end
	state:keypressed(key)
end

function love.joystickpressed(joystick, button)
	state:joystickpressed(joystick, button)
end
