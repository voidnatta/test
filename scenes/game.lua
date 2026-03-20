local love = require("love")

local Utils = require("src.utils")
local Timer = require("lib.hump.timer")

local Player = require("src.player")
local SteakCounter = require("src.steak_counter")

local Game = {}

function Game:init()
    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 0, true)
    love.graphics.setFont(love.graphics.newFont(18))

    self.entities = {}

    self.player = Player({x = 0, y = 0}, {w = 30, h = 30}, 300)
    local SteakCounter1 = SteakCounter({x = 200, y = 200}, {w = 50, h = 50})

    table.insert(self.entities, self.player)
    table.insert(self.entities, SteakCounter1)
    for _, entity in ipairs(self.entities) do
        entity:load(self.world)
    end
end

function Game:update(dt)
    Timer.update(dt)
    Utils.update()

    self.world:update(dt)
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
end

function Game:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

return Game