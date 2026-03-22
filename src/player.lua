local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local Utils = require("src.utils")

local DynamicEntity = require("src.dynamic_entity")

local Player = Class{
    __includes = DynamicEntity,
    init = function(self, position, size, speed)
        DynamicEntity.init(self, position, size, "dynamic")

        self.speed = speed or 300
        self.area_radius = 40
        self.objects_in_range = {}
        self.item_object_holding = nil
        self.name = "Player"
        self.color = {1, 1, 1, 1}
    end
}

function Player:load(_game)
    DynamicEntity.load(self, _game)
end

function Player:has_item_object()
    return self.item_object_holding ~= nil
end

function Player:get_item_object()
    return self.item_object_holding
end

function Player:set_item_object(item_object)
    self.item_object_holding = item_object
end

function Player:update(dt)
    local horizontal = Utils.get_axis('a', 'd', 'leftx')
    local vertical = Utils.get_axis('w', 's', 'lefty')
    
    -- normalize player movement
    local len = math.sqrt(horizontal * horizontal + vertical * vertical)
    if len > 1 then
        horizontal = horizontal / len
        vertical = vertical / len
    end

    self.body:setLinearVelocity(horizontal * self.speed, vertical * self.speed)

    local position_x, position_y = self.body:getPosition()
    self.position.x = position_x
    self.position.y = position_y
end

function Player:draw()
    DynamicEntity.draw(self)

    -- love.graphics.setColor(0, 1, 1, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

return Player