local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local CheeseCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)
        self.name = "Cheese Counter"
    end
}

function CheeseCounter:draw()
    Counter.draw(self)
end

function CheeseCounter:on_interact(player)
    if not player:has_item_object() then
        local cheese = ItemObject(Vector(0, 0), {w = 20, h = 20}, Item.TYPES.CHEESE)
        cheese.offset = Vector(0, -player.size.h/2 - 20)
        cheese.name = "Cheese"
        cheese:set_object_parent(player)
        cheese.color = {0, 1, 1, 1}
        
        self.entities:add_entity(cheese)
    end
end

return CheeseCounter