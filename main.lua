require "math"

local function resetBall()
	ball_body:setPosition(400, 300)
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
end	

function love.load()
    love.graphics.setMode(800, 600)
    love.graphics.setBackgroundColor(34, 189, 40)

	red_score = 0
	blue_score = 0

    world = love.physics.newWorld(0, 0, 800, 600)
	world:setCallbacks(collide, nil, nil, nil)

	bound_top_body = love.physics.newBody(world, 400, 0)
	bound_top_shape = love.physics.newRectangleShape(bound_top_body, 0, 0, 800, 3)
	bound_top_shape:setData("boundary")
	bound_bottom_body = love.physics.newBody(world, 400, 600)
	bound_bottom_shape = love.physics.newRectangleShape(bound_bottom_body, 0, 0, 800, 3)
	bound_bottom_shape:setData("boundary")
	bound_left_body = love.physics.newBody(world, 0, 300)
	bound_left_shape = love.physics.newRectangleShape(bound_left_body, 0, 0, 3, 600)
	bound_left_shape:setData("boundary")
	bound_right_body = love.physics.newBody(world, 800, 300)
	bound_right_shape = love.physics.newRectangleShape(bound_right_body, 0, 0, 3, 600)
	bound_right_shape:setData("boundary")

	net_red_body = love.physics.newBody(world, 75, 300)
	net_red_shape = love.physics.newRectangleShape(net_red_body, 0,0, 50, 100)
	net_red_shape:setSensor(true)
	net_red_shape:setData("red net")

	net_blue_body = love.physics.newBody(world, 725, 300)
	net_blue_shape = love.physics.newRectangleShape(net_blue_body, 0,0, 50, 100)
	net_blue_shape:setSensor(true)
	net_blue_shape:setData("blue net")

    ball_body = love.physics.newBody(world, 400, 300, 1, 1)
	ball_body:setAngularDamping(0.4)
	ball_body:setLinearDamping(0.4)
    ball_shape = love.physics.newCircleShape(ball_body, 0, 0, 10)
	ball_shape:setData("ball")

    blue_car = love.graphics.newImage("blue.png")
    blue_car_body = love.physics.newBody(world, 550, 300, 5, 3)
    blue_car_body:setAngle(math.rad(180))
	blue_car_body:setAngularDamping(3)
	blue_car_body:setLinearDamping(1)
    blue_car_shape = love.physics.newRectangleShape(blue_car_body, 0, 0, 64, 32)
    blue_car_shape:setData("blue car")

    red_car = love.graphics.newImage("red.png")
    red_car_body = love.physics.newBody(world, 250, 300, 5, 3)
	red_car_body:setAngularDamping(3)
	red_car_body:setLinearDamping(1)
    red_car_shape = love.physics.newRectangleShape(red_car_body, 0, 0, 64, 32)
    red_car_shape:setData("red car")

	music = love.audio.newSource("dope.mod")
	music:play()

	love.graphics.setFont(love.graphics.newFont(20))

	cheer1 = love.audio.newSource("sounds/cheer-01.wav")
	cheer2 = love.audio.newSource("sounds/cheer-03.wav")
	cheer3 = love.audio.newSource("sounds/kids-cheer-01.wav")

end

function love.draw()
    love.graphics.clear()

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
    love.graphics.quad("fill", 50, 250,
                               100, 250,
                               100, 350,
                               50, 350)
    love.graphics.setColor(0, 0, 200)
    love.graphics.quad("fill", 700, 250,
                               750, 250,
                               750, 350,
                               700, 350)

	--draw the score
	love.graphics.setColor(255, 255, 255)

	love.graphics.print(tostring(red_score), 60, 300)
	love.graphics.print(tostring(blue_score), 710, 300)

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
	local distance_x, distance_y = 400 - ball_x, 300 - ball_y
	ball_body:applyForce(distance_x/40, distance_y/40)
end

function love.keypressed(key)
	if key == "y" then
		resetBall()
	elseif key == "escape" then
		love.event.push("q")
	end
end
