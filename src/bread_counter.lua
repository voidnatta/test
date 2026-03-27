local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local BreadCounter = Class {
    __includes = Counter,
    init = function(self, position)
        Counter.init(self, position)
        self.name = "Bread Counter"
    end
}

function BreadCounter:draw()
    Counter.draw(self)
end

function BreadCounter:on_interact(player)
    if not player:has_item_object() then
        local bread = ItemObject(Vector(0, 0), Item.TYPES.BREAD)
        bread.offset = Vector(16, 21)
        bread.name = "Bread"
        bread:set_object_parent(player)
        bread.color = {0, 1, 1, 1}
        
        local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:play()

        self.entities:add_entity(bread)
    elseif player:get_item_object():is_container() then
        if player:get_item_object():has_space() then
            player:get_item_object():place_item({
                type = Item.TYPES.BREAD,
                state = {
                    cooked = false,
                    sliced = false
                }
            })
        end
    end
end

return BreadCounter