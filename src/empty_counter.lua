local love = require("love")

local Class = require("lib.hump.class")
local Counter = require("src.base.counter")
local Item = require("src.item")
local Recipe = require("src.recipe")
local Vector = require("lib.hump.vector")

local img_empty_counter = love.graphics.newImage("assets/export/empty_counter.png")

local EmptyCounter = Class {
    __includes = Counter,
    init = function(self, position)
        Counter.init(self, position)

        self.name = "Empty Counter"
        self.area_radius = 40
        self.interactable = true
    end
}

function EmptyCounter:on_interact(player)
    if self:has_item_object() and player:has_item_object() then
        local a = player:get_item_object()
        local b = self:get_item_object()

        local container = nil
        local content = nil

        if a:is_container() and b:can_be_contained() then
            container = a
            content = b
        elseif b:is_container() and a:can_be_contained() then
            container = b
            content = a
        else 
            return
        end

        if container.items and #container.items < container.max_items then
            table.insert(container.items, {
                type = content.type,
                state = content.state
            })

            content:queue_free()
            content:set_object_parent(nil)

            local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
            action_sound:setVolume(0.2)
            action_sound:play()
        else
            print("Container is not empty")
        end

        -- container:set_object_parent(player)
        return
    end

    if player:has_item_object() then
        local item_obj = player:get_item_object()
        item_obj:set_object_parent(self)
        
        local action_sound = love.audio.newSource("assets/sfx/pop5.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:setPitch(0.8)
        action_sound:play()
        
    elseif self:has_item_object() then
        self:get_item_object():set_object_parent(player)
        local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:play()
    else
        print("Nothing happens")
    end
end

function EmptyCounter:draw()
    Counter.draw(self)
end

return EmptyCounter


-- local action_type_handler = {
--     [Item.TYPES.PLATE] = function(self, player)
--         print("EmptyCounter is holding a plate. Cannot place on counter.")
--     end,
--     [Item.TYPES.STEAK] = function(self, player)
--         local player_item = player:get_item_object()
--         if player_item.type == Item.TYPES.PLATE then
--             if player_item.items and #player_item.items == 0 then
--                 player_item.items[#player_item.items + 1] = Item.TYPES.STEAK
--                 self:get_item_object():queue_free()
--                 self:get_item_object():set_object_parent(nil)
--             else
--                 print("Player is holding a plate, but it's not empty. Cannot place on counter.")
--             end
--         end
--     end
-- }