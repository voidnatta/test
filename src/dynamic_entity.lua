local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local Entity = require("src.base.entity")

local DynamicEntity = Class{
    __includes = Entity,
    init = function (self, position, size, body_type)
        Entity.init(self, position, size)

        self.body = nil
        self.shape = nil
        self.fixture = nil
        self.body_type = body_type or "dynamic"
    end,
    load = function(self, game)
        Entity.load(self, game)
        self.body = love.physics.newBody(game.world, self.position.x, self.position.y, self.body_type)
        self.shape = love.physics.newRectangleShape(self.size.w, self.size.h)
        self.fixture = love.physics.newFixture(self.body, self.shape)
    ---@diagnostic disable-next-line: undefined-field
        self.body:setFixedRotation(true)
    end,
    update = function(self, dt)
        -- to be overridden by subclasses
    end,
    draw = function(self)
        Entity.draw(self)
        if not DEBUGMODE then return end

        if self.body and self.shape then
            love.graphics.setColor(1, 0, 0, 0.5) -- red with transparency

            love.graphics.push()
            love.graphics.translate(self.body:getX(), self.body:getY())
            love.graphics.rotate(self.body:getAngle())
            love.graphics.setLineWidth(5)

            love.graphics.rectangle(
                "line",
                -self.size.w / 2,
                -self.size.h / 2,
                self.size.w,
                self.size.h,13
            )

            love.graphics.pop()

            love.graphics.setColor(1, 1, 1, 1) -- reset color
        end
    end,

    destroy = function(self)
        if self.fixture and self.fixture.destroy then
            self.fixture:destroy()
            self.fixture = nil
        end

        if self.body and self.body.destroy then
            self.body:destroy()
            self.body = nil
        end

        self.shape = nil
        self.entities = nil
    end,
}

return DynamicEntity