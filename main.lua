local state = nil

function love.load()
	love.graphics.setMode(800, 600, true)

	love.filesystem.setIdentity("Crash 'Em Bash 'Em")

	logging = love.filesystem.newFile("logfile.txt")
	logging:open("a")

	state = require "states.mainmenu"
	while not state:load() do end
end

function love.draw()
	state:draw()
end

function love.update(dt)
	state = state:update(dt)
	if state == nil then
		love.event.push("q")
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("q")
	end
	state:keypressed(key)
end
