local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local Entity = require("src.base.entity")

local DynamicEntity = Class{
    __includes = Entity,
    init = function (self, position, body_type)
        Entity.init(self, position)

        self.body = nil
        self.shape = nil
        self.fixture = nil
        self.body_type = body_type or "dynamic"
        self.custom_shape_size = Vector(0, 0)
    end,
    load = function(self, game)
        Entity.load(self, game)
        self.body = love.physics.newBody(game.world, self.position.x, self.position.y, self.body_type)
        if not (self.custom_shape_size.x == 0 and self.custom_shape_size.y == 0) then
            self.shape = love.physics.newRectangleShape(self.custom_shape_size.x, self.custom_shape_size.y)

        else
            self.shape = love.physics.newRectangleShape(self.size.x, self.size.y)
        end
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
            
            if self.custom_shape_size.x ~= 0 and self.custom_shape_size.y ~= 0 then
                love.graphics.rectangle(
                    "line",
                    -self.custom_shape_size.x / 2,
                    -self.custom_shape_size.y / 2,
                    self.custom_shape_size.x,
                    self.custom_shape_size.y,13
                )
            else
                love.graphics.rectangle(
                    "line",
                    -self.size.x / 2,
                    -self.size.y / 2,
                    self.size.x,
                    self.size.y,13
                )
            end

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