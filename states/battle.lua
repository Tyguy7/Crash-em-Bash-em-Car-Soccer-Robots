require "math"
require "table"

require "libs.middleclass"
require "libs.art"
local Soundtrack = require "libs.soundtrack"

local Car = require "objects.car"
local Monster = require "objects.monster"
local Net = require "objects.net"
local Ball = require "objects.ball"
local Fans = require "objects.fans"

local Battle = class("Battle")

local function vectorLength(x, y)
    return math.sqrt(x*x + y*y)
end

function Battle:startCrashParticle(position, impact)
    local system = self.particle_systems[self.particle_systems.next]
    self.particle_systems.next = ((self.particle_systems.next + 1)%10) + 1
    if system then
        system:setPosition(position[1], position[2])
        system:setDirection(math.atan2(impact[2], impact[1]))
        local impact_force = vectorLength(impact[2], impact[1])
        system:setEmissionRate(impact_force*80)
        if not system:isActive() then
            system:start()
        end
    end
end

local function makeCollide(state)
    local function collide(a, b, collision)
        local objects = {}
        if a then
            objects[a] = true
        end
        if b then
            objects[b] = true
        end
        if objects["red net"] and objects["ball"] then
            state.fans:goalScored()
            state.blue_score = state.blue_score + 1
            state.ball:reset()
        end
        if objects["blue net"] and objects["ball"] then
            state.fans:goalScored()
            state.red_score = state.red_score + 1
            state.ball:reset()
        end
        if a == "car" and b == "car" then
            if state.crash3:isStopped() and state.hornCrashCounter < 0 then
                state.crash3:play()
                state.hornCrashCounter = 500
            end
            state:startCrashParticle({collision:getPosition()},
                                     {collision:getVelocity()})
        end
        if objects["boundary"] and objects["car"] then
            state:playCrash()
            state:startCrashParticle({collision:getPosition()},
                                     {collision:getVelocity()})
        end
    end
    return collide
end

function Battle:playCrash()
    rnum = math.random(3)
    if rnum == 1 then
        self.crash2:stop()
        self.crash1:play()
    end
    if rnum == 2 then
        self.crash1:stop()
        self.crash2:play()
    end
end

function Battle:initialize(num_players)
    self.num_players = num_players
end

function Battle:load()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setBackgroundColor(34, 189, 40)

    self.red_score = 0
    self.blue_score = 0

    local world = love.physics.newWorld(0, 0, 800, 600)
    world:setCallbacks(makeCollide(self), nil, nil, nil)
    self.world = world

    bound_bottom_body = love.physics.newBody(world, 400, 600)
    bound_bottom_shape = love.physics.newRectangleShape(bound_bottom_body, 0, 0, 800, 3)
    bound_bottom_shape:setData("boundary")
    bound_left_body = love.physics.newBody(world, 0, 350)
    bound_left_shape = love.physics.newRectangleShape(bound_left_body, 0, 0, 3, 600)
    bound_left_shape:setData("boundary")
    bound_right_body = love.physics.newBody(world, 800, 350)
    bound_right_shape = love.physics.newRectangleShape(bound_right_body, 0, 0, 3, 600)
    bound_right_shape:setData("boundary")

    local cars = nil
    if self.num_players == 2 then
        cars = {Monster(1, 2, world), Monster(2, 2, world),}
    elseif self.num_players == 4 then
        cars = {Monster(1, 4, world), Monster(2, 4, world),
                Monster(3, 4, world), Monster(4, 4, world)}
    end
    local objects = {Fans(world), Ball(world), Net(1, world), Net(2, world)}
    self.fans = objects[1]
    self.ball = objects[2]
    for i, car in ipairs(cars) do
        table.insert(objects, 2, car)
    end


    self.objects = objects

    self.soundtrack = Soundtrack{"dope.mod", "iphar_aldeas_funk.mod"}
    self.soundtrack:play()

    --art("game start.ogg"):play()

    love.graphics.setFont(love.graphics.newFont(20))

    self.crash1 = art("crash-01.ogg")
    self.crash2 = art("crash-02.ogg")
    self.crash3 = art("crash-03.ogg")
    self.hornCrashCounter = -1

    self.spark = art("spark.png")
    self.particle_systems = {next=1}
    for i = 1, 10 do
        local system = love.graphics.newParticleSystem(self.spark, 20)
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
        table.insert(self.particle_systems, system)
    end
end

function Battle:draw()
    love.graphics.clear()

    --draw the game objects
    for i, object in ipairs(self.objects) do
        object:draw()
    end

    -- draw particles
    for i, system in ipairs(self.particle_systems) do
        love.graphics.draw(system)
    end

    --draw the score
    love.graphics.setColor(255, 255, 255)

    love.graphics.print(tostring(self.red_score), 60, 350)
    love.graphics.print(tostring(self.blue_score), 710, 350)
end

function Battle:update()
    self.world:update(1/60)

    self.hornCrashCounter = self.hornCrashCounter - 1

    for i, system in ipairs(self.particle_systems) do
        system:update(1/60)
    end

    for i, object in ipairs(self.objects) do
        object:update()
    end

    return self
end

function Battle:keypressed(key) end

return Battle
