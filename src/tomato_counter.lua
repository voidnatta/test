local love = require("love")
local Item = require("src.item")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Counter = require("src.base.counter")
local ItemObject = require("src.item_object")

local TomatoCounter = Class {
    __includes = Counter,
    init = function(self, position)
        Counter.init(self, position)
        self.name = "Tomato Counter"
    end
}

function TomatoCounter:draw()
    Counter.draw(self)
end

function TomatoCounter:on_interact(player)
    if not player:has_item_object() then
        local tomato = ItemObject(Vector(0, 0), Item.TYPES.TOMATO)
        tomato.offset = Vector(0, -player.size.y/2 - 20)
        tomato.name = "Tomato"
        tomato:set_object_parent(player)
        tomato.color = {0, 1, 1, 1}
        
        local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:play()

        self.entities:add_entity(tomato)
    elseif player:get_item_object():is_container() then
        if player:get_item_object():has_space() then
            player:get_item_object():place_item({
                type = Item.TYPES.TOMATO,
                state = {
                    cooked = false,
                    sliced = false
                }
            })
        end
    end
end

return TomatoCounter