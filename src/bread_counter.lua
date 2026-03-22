local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local BreadCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)
        self.name = "Steak Counter"
    end
}

function BreadCounter:draw()
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(1, 1, 0.5, 1)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)

    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

function BreadCounter:on_interact(player)
    if not player:has_item_object() then
        local bread = ItemObject(Vector(0, 0), {w = 20, h = 20}, Item.TYPES.BREAD)
        bread.offset = Vector(0, -player.size.h/2 - 20)
        bread.name = "Bread"
        bread:set_object_parent(player)
        bread.color = {0, 1, 1, 1}
        
        self.entities:add_entity(bread)
    end
end

return BreadCounter