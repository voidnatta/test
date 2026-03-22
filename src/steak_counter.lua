local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local SteakCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)
        self.name = "Steak Counter"
    end
}

function SteakCounter:draw()
    Counter.draw(self)
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(1, 1, 0.5, 1)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)

    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

function SteakCounter:on_interact(player)
    if not player:has_item_object() then
        local steak = ItemObject(Vector(0, 0), {w = 20, h = 20}, Item.TYPES.STEAK)
        steak.offset = Vector(0, -player.size.h/2 - 20)
        steak.name = "Steak"
        steak:set_object_parent(player)
        
        self.entities:add_entity(steak)
    end
end

return SteakCounter