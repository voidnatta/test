local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local PlateObject = require("src.plate")

local PlateCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)
        self.name = "Plate Counter"
        self.color = {.7, 0.7, .7, 1}
    end
}

function PlateCounter:draw()
    Counter.draw(self)
end

function PlateCounter:on_interact(player)
    if player:has_item_object() then
        if player:get_item_object().type == Item.TYPES.PLATE then
            -- destroy plate object if its content's empty
            if #player:get_item_object().items == 0 then
                player:get_item_object():queue_free()
                player:get_item_object():set_object_parent(nil)
            else
                print("Player is holding a plate, but it's not empty. Cannot place on counter.")
            end
            return
        end
        return
    end
    
    if not player:has_item_object() then
        local plate = PlateObject(Vector(0, 0), {w = 20, h = 20}, Item.TYPES.PLATE)
        plate.offset = Vector(0, -player.size.h/2 - 20)
        plate.name = "Plate"
        plate:set_object_parent(player)
        
        self.entities:add_entity(plate)
    end
end

return PlateCounter