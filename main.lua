require "math"

local function resetBall()
	ball_body:setPosition(400, 350)
	ball_body:setLinearVelocity(0, 0)
end

function collide(a, b)
	objects = {}
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
	end
	if objects["boundary"] then
		playCrash()
	end
	if objects["blue car"] and objects["red car"] then
		crash3:play()
	end
	if objects["boundary"] then
		playCrash()
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
	fanpic = "cheer1.png"
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

	net_red_body = love.physics.newBody(world, 75, 350)
	net_red_shape = love.physics.newRectangleShape(net_red_body, 0,0, 50, 100)
	net_red_shape:setSensor(true)
	net_red_shape:setData("red net")

	net_blue_body = love.physics.newBody(world, 725, 350)
	net_blue_shape = love.physics.newRectangleShape(net_blue_body, 0,0, 50, 100)
	net_blue_shape:setSensor(true)
	net_blue_shape:setData("blue net")

    ball_body = love.physics.newBody(world, 400, 350, 1, 1)
	ball_body:setAngularDamping(0.4)
	ball_body:setLinearDamping(0.4)
    ball_shape = love.physics.newCircleShape(ball_body, 0, 0, 10)
	ball_shape:setData("ball")

    blue_car = love.graphics.newImage("blue.png")
    blue_car_body = love.physics.newBody(world, 550, 350, 5, 3)
    blue_car_body:setAngle(math.rad(180))
	blue_car_body:setAngularDamping(3)
	blue_car_body:setLinearDamping(1)
    blue_car_shape = love.physics.newRectangleShape(blue_car_body, 0, 0, 64, 32)
    blue_car_shape:setData("blue car")

    red_car = love.graphics.newImage("red.png")
    red_car_body = love.physics.newBody(world, 250, 350, 5, 3)
	red_car_body:setAngularDamping(3)
	red_car_body:setLinearDamping(1)
    red_car_shape = love.physics.newRectangleShape(red_car_body, 0, 0, 64, 32)
    red_car_shape:setData("red car")

	music = love.audio.newSource("dope.mod")
	music:play()

	love.graphics.setFont(love.graphics.newFont(20))

	cheer1 = love.audio.newSource("sounds/cheer-01.wav", "static")
	cheer2 = love.audio.newSource("sounds/cheer-03.wav", "static")
	cheer3 = love.audio.newSource("sounds/kids-cheer-01.wav", "static")

	crash1 = love.audio.newSource("sounds/crash-01.wav", "static")
	crash2 = love.audio.newSource("sounds/crash-02.wav", "static")
	crash3 = love.audio.newSource("sounds/crash-03.wav", "static")

	screech1 = love.audio.newSource("sounds/screech.wav", "static")
	screech1:setVolume(0.2)
	screech1:setLooping(true)

	screech2 = love.audio.newSource("sounds/screech.wav", "static")
	screech2:setVolume(0.2)
	screech2:setLooping(true)

	tire_mark = love.graphics.newImage("tiremark.png")
	tire_mark_list = {}
end

fanpic = "fans.png"
fanint = 0

function love.draw()
    love.graphics.clear()

    --draw the fans
    if fanpic ~= "fans.png" then
	fanint = fanint + 1
	if fanint > 30 and fanint <= 60 then
	     fanpic = "cheer2.png"
	end
	if fanint > 60 and fanint <= 90 then
	     fanpic = "cheer3.png"
	end
	if fanint > 90 then
	     fanpic = "fans.png"
	     fanint = 0
	end
    end
    fans = love.graphics.newImage(fanpic)
    love.graphics.draw(fans, 0, 0, 0, 1, 1, 0, 0)

    --draw the cars
    local world_x, world_y = blue_car_body:getWorldPoint(0,0)
    love.graphics.draw(blue_car, world_x, world_y,
                       blue_car_body:getAngle(), 1, 1, 32, 32)

    world_x, world_y = red_car_body:getWorldPoint(0,0)
    love.graphics.draw(red_car, world_x, world_y,
                       red_car_body:getAngle(), 1, 1, 32, 32)

    --draw the ball
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", ball_body:getX(), ball_body:getY(),
                         ball_shape:getRadius(), 20)

    --draw the nets
    love.graphics.setColor(200, 0, 0)
    love.graphics.quad("fill", 50, 300,
                               100, 300,
                               100, 400,
                               50, 400)
    love.graphics.setColor(0, 0, 200)
    love.graphics.quad("fill", 700, 300,
                               750, 300,
                               750, 400,
                               700, 400)

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

end

function love.update()
    world:update(1/60)

	--blue car movement
	if love.keyboard.isDown("left") then
		blue_car_body:applyTorque(-40)
	end
	if love.keyboard.isDown("right") then
		blue_car_body:applyTorque(40)
	end
	if love.keyboard.isDown("up") then
		blue_car_body:applyForce(blue_car_body:getWorldVector(160,0))
	end
	if love.keyboard.isDown("down") then
		blue_car_body:applyForce(blue_car_body:getWorldVector(-60,0))
	end

	--red car movement
	if love.keyboard.isDown("a") then
		red_car_body:applyTorque(-40)
	end
	if love.keyboard.isDown("d") then
		red_car_body:applyTorque(40)
	end
	if love.keyboard.isDown("w") then
		red_car_body:applyForce(red_car_body:getWorldVector(160,0))
	end
	if love.keyboard.isDown("s") then
		red_car_body:applyForce(red_car_body:getWorldVector(-60,0))
	end

	--ball "gravity" towards center of screen
	local ball_x, ball_y = ball_body:getPosition()
	local distance_x, distance_y = 400 - ball_x, 350 - ball_y
	ball_body:applyForce(distance_x/40, distance_y/40)

	if shouldScreech(blue_car_body) then
		if not blue_car_screeching then
			screech1:play()
		end
		tireMarks(blue_car_body)
		blue_car_screeching = true
	elseif blue_car_screeching then
		screech1:stop()
		blue_car_screeching = false
	end

	if shouldScreech(red_car_body) then
		if not red_car_screeching then
			screech1:play()
		end
		tireMarks(red_car_body)
		red_car_screeching = true
	elseif red_car_screeching then
		screech1:stop()
		red_car_screeching = false
	end
end

function love.keypressed(key)
	if key == "y" then
		resetBall()
	elseif key == "escape" then
		love.event.push("q")
	end
end
