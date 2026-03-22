local love = require("love")

local Class = require("lib.hump.class")
local Entity = require("src.base.entity")
local Item = require("src.item")

local ItemObject = Class{
    __includes = Entity,
    init = function(self, position, size, type)
        Entity.init(self, position, size)
        self.position = position
        self.size = size
        self.type = type
        self.state = {
            sliced = false,
            cooked = false,
            overcooked = false
        }
    end,
}

function ItemObject:is_container()
    return self.type == Item.TYPES.PLATE
end

function ItemObject:can_be_contained() 
    return self.type ~= Item.TYPES.PLATE
end

function ItemObject:set_object_parent(parent)
    
    if self.parent then
        if self.parent.set_item_object then
            self.parent:set_item_object(nil)
        end
        -- print("Warning: ItemObject already has a parent. Overwriting.")
    end

    self.parent = parent
    if parent and parent.set_item_object then
        parent:set_item_object(self)
    end
end

function ItemObject:on_interact(player)
    -- print("Player interacted with item: " .. self.type) 
    -- if player.item_holding then
    --     print("Player is already holding an item.")
    --     return
    -- end

    -- player.item_holding = self
    -- self.interactable = false
    -- self.parent = player
    -- self.offset = {
    --     x = 0,
    --     y = -player.size.h/2 - 20
    -- }

    -- -- Update item position to be relative to the player
    -- self.position.x = player.position.x + self.offset.x
    -- self.position.y = player.position.y + self.offset.y
end

function ItemObject:draw()
    if self.parent then
        -- If the item is being held, draw it relative to the parent (player)
        self.position.x = self.parent.position.x + self.offset.x
        self.position.y = self.parent.position.y + self.offset.y
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', self.position.x - self.size.w/2, self.position.y - self.size.h/2, self.size.w, self.size.h)
    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', self.position.x, self.position.y, 20)

    -- Draw item type text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.type, self.position.x - 25, self.position.y - 35)
end

return ItemObject