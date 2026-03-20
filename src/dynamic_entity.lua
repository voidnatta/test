local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local Entity = require("src.entity")

local DynamicEntity = Class{
    __includes = Entity,
    init = function (self, position, size, body_type)
        Entity.init(self, position, size)

        self.body = nil
        self.shape = nil
        self.fixture = nil
        self.body_type = body_type or "dynamic"
    end,
    load = function(self, world)
        self.body = love.physics.newBody(world, self.position.x, self.position.y, self.body_type)
        self.shape = love.physics.newRectangleShape(self.size.w, self.size.h)
        self.fixture = love.physics.newFixture(self.body, self.shape)
    ---@diagnostic disable-next-line: undefined-field
        self.body:setFixedRotation(true)
    end,
    update = function(self, dt)
        -- to be overridden by subclasses
    end,
    draw = function(self)
        -- to be overridden by subclasses
    end,
}

return DynamicEntity