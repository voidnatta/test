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
    DynamicEntity.draw(self)
end

return Counter