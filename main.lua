require "math"
require "table"

local Car = require "objects.car"
local Monster = require "objects.monster"
local Net = require "objects.net"
local Ball = require "objects.ball"

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
function collide(a, b)
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
    end
    if objects["boundary"] then
        playCrash()
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
		resetBall()
	end
	if objects["blue net"] and objects["ball"] then
		playGoal()
		red_score = red_score + 1
		resetBall()
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
	for i = 1, 50 do
		local location = {math.random(0, 800), math.random(0, 100), math.random(50)}
		table.insert(flashes, location)
	end
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

    ball = Ball(world)

	red_car = Car(1, 2, world)
	blue_car = Monster(2, 2, world)

	music = love.audio.newSource("res/music/dope.mod")
	music:setLooping(true)
	music:play()

    red_net = Net(1, world)
    blue_net = Net(2, world)

	announcer = love.audio.newSource("res/sounds/title.wav")
	announcer:play()

	love.graphics.setFont(love.graphics.newFont(20))

	cheer1 = love.audio.newSource("res/sounds/cheer-01.wav", "static")
	cheer2 = love.audio.newSource("res/sounds/cheer-03.wav", "static")
	cheer3 = love.audio.newSource("res/sounds/kids-cheer-01.wav", "static")

	crash1 = love.audio.newSource("res/sounds/crash-01.wav", "static")
	crash2 = love.audio.newSource("res/sounds/crash-02.wav", "static")
	crash3 = love.audio.newSource("res/sounds/crash-03.wav", "static")

	screech1 = love.audio.newSource("res/sounds/screech.wav", "static")
	screech1:setVolume(0.2)
	screech1:setLooping(true)

	screech2 = love.audio.newSource("res/sounds/screech.wav", "static")
	screech2:setVolume(0.2)
	screech2:setLooping(true)

	tire_mark = love.graphics.newImage("res/images/tiremark.png")
	tire_marks_list = {}

	fans = love.graphics.newImage("res/images/fans.png")

	flash = love.graphics.newImage("res/images/flash.png")
	flashes = {}

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

	--draw the tiremarks
	for i, location in ipairs(tire_marks_list) do
		if location[3] > 60 then
			alpha = 255
		elseif location[3] <= 0 then
			alpha = 0
		else
			alpha = location[3]*255/60
		end
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(tire_mark, location[1], location[2], 0, 1, 1, 2, 2)
	end
	love.graphics.setColor(255,255,255)

	--draw the fans
	love.graphics.draw(fans, 0, 0, 0, 1, 1, 0, 0)

	--draw any camera flashes
	for i, location in ipairs(flashes) do
		if location[3] < 2 then
			love.graphics.draw(flash, location[1], location[2], 0, 1, 1, 64, 64)
		end
	end

	--draw the cars
	blue_car:draw()
	red_car:draw()

	for i, system in ipairs(particle_systems) do
		love.graphics.draw(system)
	end

    --draw the ball
    ball:draw()

    --draw the nets
    red_net:draw()
    blue_net:draw()

    --draw the score
    love.graphics.setColor(255, 255, 255)

    love.graphics.print(tostring(red_score), 60, 350)
    love.graphics.print(tostring(blue_score), 710, 350)
end

local function normAngle(angle)
	return angle % math.pi*2
end

local function difference(a1, a2)
	a1, a2 = normAngle(a1), normAngle(a2)
	if a1 > a2 then
		a1, a2 = a2, a1
	end
	return (a2 - a1)%math.pi
end

local function shouldScreech(car_body)
	velocity_x, velocity_y = car_body:getLinearVelocity()
	velocity_angle = math.atan2(velocity_y, velocity_x)
	if math.abs(velocity_y) + math.abs(velocity_y) < 60 then
		return nil
	end
	return difference(velocity_angle, car_body:getAngle()) > math.rad(40)
end

local function tireMarks(car_body)
	local locations = {{28,-16},{28,16},{-22,16},{-22,-16}}
	for i, location in ipairs(locations) do
		local new = {car_body:getWorldPoint(location[1], location[2])}
		new[3] = 200
		table.insert(tire_marks_list, new)
	end
end

function love.update()
	world:update(1/60)

	blue_car:update()
	red_car:update()

	for i, system in ipairs(particle_systems) do
		system:update(1/60)
	end

	ball:update()

	if shouldScreech(blue_car.body) then
		if not blue_car_screeching then
			screech1:play()
		end
		tireMarks(blue_car.body)
		blue_car_screeching = true
	elseif blue_car_screeching then
		screech1:stop()
		blue_car_screeching = false
	end

	if shouldScreech(red_car.body) then
		if not red_car_screeching then
			screech1:play()
		end
		tireMarks(red_car.body)
		red_car_screeching = true
	elseif red_car_screeching then
		screech1:stop()
		red_car_screeching = false
	end

	local remove = {}
	for i, location in ipairs(tire_marks_list) do
		location[3] = location[3] - 1
		if location[3] <= 0 then
			table.insert(remove, i)
		end
	end
	for i, remove_index in ipairs(remove) do
		table.remove(tire_marks_list, remove_index)
	end

	remove = {}
	for i, location in ipairs(flashes) do
		location[3] = location[3] - .8
		if location[3] <= 0 then
			table.insert(remove, i)
		end
	end
	for i, remove_index in ipairs(remove) do
		table.remove(flashes, remove_index)
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
