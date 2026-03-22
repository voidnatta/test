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
    Counter.draw(self)
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