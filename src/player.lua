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
        self.item_holding = nil
    end
}

function Player:load(_world)
    DynamicEntity.load(self, _world)
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
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)
    -- love.graphics.setColor(0, 1, 1, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

return Player

-- function player:drop_item()
--     if self.item_holding then
--         -- Remove the item from the entities list
--         self.item_holding.parent = nil
--         self.item_holding.interactable = true
--         self.item_holding = nil
--     end
-- end