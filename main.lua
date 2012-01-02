require "math"
require "table"

local Car = require "objects.car"
local Monster = require "objects.monster"
local Net = require "objects.net"
local Ball = require "objects.ball"
local Fans = require "objects.fans"

local function vectorLength(x, y)
	return math.sqrt(x*x + y*y)
end

local function startCrashParticle(position, impact)
	local system = particle_systems[particle_systems.next]
	particle_systems.next = ((particle_systems.next + 1)%10) + 1
	if system then
		system:setPosition(position[1], position[2])
		system:setDirection(math.atan2(impact[2], impact[1]))
		impact_force = vectorLength(impact[2], impact[1])
		system:setEmissionRate(impact_force*80)
		if not system:isActive() then
			system:start()
		end
	end
end

function collide(a, b, collision)
	local objects = {}
	if a then
		objects[a] = true
	end
	if b then
		objects[b] = true
	end
	if objects["red net"] and objects["ball"] then
		playGoal()
		blue_score = blue_score + 1
		ball:reset()
	end
	if objects["blue net"] and objects["ball"] then
		playGoal()
		red_score = red_score + 1
		ball:reset()
	end
	if objects["blue car"] and objects["red car"] then
		crash3:play()
		startCrashParticle({collision:getPosition()},
						   {collision:getVelocity()})
	end
	if objects["boundary"] and (objects["blue car"] or objects["red car"]) then
		playCrash()
		startCrashParticle({collision:getPosition()},
						   {collision:getVelocity()})
	end
end

function playGoal()
	rnum = math.random(3)
	if rnum == 1 then
		cheer1:play()
	end
	if rnum == 2 then
		cheer2:play()
	end
	if rnum == 3 then
		cheer3:play()
	end
	fans:startGoalFlashes()
end

function playCrash()
	rnum = math.random(3)
	if rnum == 1 then
		crash2:stop()
		crash1:play()
	end
	if rnum == 2 then
		crash1:stop()
		crash2:play()
	end
end

function love.load()
	love.graphics.setMode(800, 600)
	love.graphics.setBackgroundColor(34, 189, 40)

	red_score = 0
	blue_score = 0

	world = love.physics.newWorld(0, 0, 800, 600)
	world:setCallbacks(collide, nil, nil, nil)

	bound_top_body = love.physics.newBody(world, 400, 100)
	bound_top_shape = love.physics.newRectangleShape(bound_top_body, 0, 0, 800, 3)
	bound_top_shape:setData("boundary")
	bound_bottom_body = love.physics.newBody(world, 400, 600)
	bound_bottom_shape = love.physics.newRectangleShape(bound_bottom_body, 0, 0, 800, 3)
	bound_bottom_shape:setData("boundary")
	bound_left_body = love.physics.newBody(world, 0, 350)
	bound_left_shape = love.physics.newRectangleShape(bound_left_body, 0, 0, 3, 600)
	bound_left_shape:setData("boundary")
	bound_right_body = love.physics.newBody(world, 800, 350)
	bound_right_shape = love.physics.newRectangleShape(bound_right_body, 0, 0, 3, 600)
	bound_right_shape:setData("boundary")

	objects = {Fans(world), Car(1, 2, world), Monster(2, 2, world), Ball(world),
			   Net(1, world), Net(2, world)}
	fans = objects[1]
	blue_car = objects[2]
	red_car = objects[3]
	ball = objects[4]

	music = love.audio.newSource("res/music/dope.mod")
	music:setLooping(true)
	music:play()

	announcer = love.audio.newSource("res/sounds/title.wav")
	announcer:play()

	love.graphics.setFont(love.graphics.newFont(20))

	cheer1 = love.audio.newSource("res/sounds/cheer-01.wav", "static")
	cheer2 = love.audio.newSource("res/sounds/cheer-03.wav", "static")
	cheer3 = love.audio.newSource("res/sounds/kids-cheer-01.wav", "static")

	crash1 = love.audio.newSource("res/sounds/crash-01.wav", "static")
	crash2 = love.audio.newSource("res/sounds/crash-02.wav", "static")
	crash3 = love.audio.newSource("res/sounds/crash-03.wav", "static")

	spark = love.graphics.newImage("res/images/spark.png")
	particle_systems = {next=1}
	for i = 1, 10 do
		local system = love.graphics.newParticleSystem(spark, 20)
		system:setLifetime(.2)
		system:setEmissionRate(120)
		system:setParticleLife(1)
		system:setSpread(2.5)
		system:setSpeed(10,120)
		system:setRadialAcceleration(10)
		system:setTangentialAcceleration(0)
		system:setSize(1)
		system:setSizeVariation(0.5)
		system:setRotation(0)
		system:setSpin(0)
		system:setSpinVariation(0)
		system:setColor(255,255,255,240,255,255,255,10)
		system:stop()
		table.insert(particle_systems, system)
	end
end

local function carSwitch(car)
    if car.class.name == "Car" then
    car = Monster(car.player, 2, world)
    elseif car.class.name == "Monster" then
    car = Car(car.player, 2, world)
    end
    return car
end

function love.draw()
	love.graphics.clear()

	--draw the game objects
	for i, object in ipairs(objects) do
		object:draw()
	end


	-- draw particles
	for i, system in ipairs(particle_systems) do
		love.graphics.draw(system)
	end

    --draw the score
    love.graphics.setColor(255, 255, 255)

    love.graphics.print(tostring(red_score), 60, 350)
    love.graphics.print(tostring(blue_score), 710, 350)
end

function love.update()
	world:update(1/60)

	for i, system in ipairs(particle_systems) do
		system:update(1/60)
	end

	for i, object in ipairs(objects) do
		object:update()
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("q")
	elseif key == "m" then
        blue_car = carSwitch(blue_car);
	elseif key == "v" then
        red_car = carSwitch(red_car);
	end
end
