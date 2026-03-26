local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local SteakCounter = Class {
    __includes = Counter,
    init = function(self, position)
        Counter.init(self, position)
        self.name = "Steak Counter"
    end
}

function SteakCounter:draw()
    Counter.draw(self)
end

function SteakCounter:on_interact(player)
    if not player:has_item_object() then
        local steak = ItemObject(Vector(0, 0), Item.TYPES.STEAK)
        steak.name = "Steak"
        steak:set_object_parent(player)
        
        local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:play()

        self.entities:add_entity(steak)
    elseif player:get_item_object():is_container() then
        if player:get_item_object():has_space() then
            player:get_item_object():place_item({
                type = Item.TYPES.STEAK,
                state = {
                    cooked = false,
                    sliced = false
                }
            })
        end
    end
end

return SteakCounter