local love = require("love")

local Class = require("lib.hump.class")
local DynamicEntity = require("src.dynamic_entity")

local Counter = Class {
    __includes = DynamicEntity,
    init = function(self, position, size)
        DynamicEntity.init(self, position, size, "static")

        self.area_radius = 40
        self.interactable = true
        self.item_object_holding = nil
    end
}

function Counter:get_item_object()
    return self.item_object_holding
end

function Counter:has_item_object()
    return self.item_object_holding ~= nil
end

function Counter:set_item_object(item_object)
    self.item_object_holding = item_object
end

function Counter:draw()
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(1, 0.5, 0.5, 1)
    love.graphics.rectangle('fill', position_x, position_y, self.size.w, self.size.h)
    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x + self.size.w/2, position_y + self.size.h/2, self.area_radius)
end

return Counter