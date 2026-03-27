local love = require("love")

local Class = require("lib.hump.class")
local Entity = require("src.base.entity")
local Item = require("src.item")
local Vector = require("lib.hump.vector")

local IMAGES = {
    [Item.TYPES.TOMATO] = love.graphics.newImage("assets/export/tomato.png"),
    [Item.TYPES.CHEESE] = love.graphics.newImage("assets/export/cheese.png"),
    [Item.TYPES.STEAK] = love.graphics.newImage("assets/export/steak.png"),
    [Item.TYPES.BREAD] = love.graphics.newImage("assets/export/bread.png")
}

local ItemObject = Class{
    __includes = Entity,
    init = function(self, position, type)
        Entity.init(self, position)
        self.position = position
        self.type = type
        self.state = {
            sliced = false,
            cooked = false,
            overcooked = false
        }
        self.z_order = 7
        self.anchor_offset = Vector(0, 0)
        self.local_draw_offset = Vector(0, 0)
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
        if parent.get_child_anchor_offset then
            self.anchor_offset = parent:get_child_anchor_offset(self) or Vector(0, 0)
        elseif parent.item_anchor_offset then
            self.anchor_offset = parent.item_anchor_offset
        elseif parent.placement_offset then
            self.anchor_offset = parent.placement_offset
        else
            self.anchor_offset = Vector(0, 0)
        end
    else
        self.anchor_offset = Vector(0, 0)
    end
end

function ItemObject:set_local_draw_offset(offset)
    self.local_draw_offset = offset or Vector(0, 0)
end

function ItemObject:on_interact(player)
    
end

local function getSizeFromImage(image) 
    return {x = image:getWidth(), y = image:getHeight()}
end

local draw_dispatcher = {
    [Item.TYPES.TOMATO] = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        if not self.state.sliced then
            love.graphics.draw(IMAGES[Item.TYPES.TOMATO], self.position.x - getSizeFromImage(IMAGES[Item.TYPES.TOMATO]).x/2, 
            self.position.y - getSizeFromImage(IMAGES[Item.TYPES.TOMATO]).y/2, 0, 1, 1)
        else
            love.graphics.draw(love.graphics.newImage("assets/export/cutted_tomato.png"), self.position.x - getSizeFromImage(love.graphics.newImage("assets/export/cutted_tomato.png")).x/2, 
            self.position.y - getSizeFromImage(love.graphics.newImage("assets/export/cutted_tomato.png")).y/2, 0, 1, 1)
        end
    end,
    [Item.TYPES.CHEESE] = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(IMAGES[Item.TYPES.CHEESE], self.position.x - getSizeFromImage(IMAGES[Item.TYPES.CHEESE]).x/2, 
        self.position.y - getSizeFromImage(IMAGES[Item.TYPES.CHEESE]).y/2, 0, 1, 1)
    end,
    [Item.TYPES.STEAK] = function(self)
        if not self.state.cooked then
            love.graphics.draw(IMAGES[Item.TYPES.STEAK], self.position.x - getSizeFromImage(IMAGES[Item.TYPES.STEAK]).x/2, 
            self.position.y - getSizeFromImage(IMAGES[Item.TYPES.STEAK]).y/2, 0, 1, 1)
        else
            love.graphics.draw(love.graphics.newImage("assets/export/steak_cooked.png"), self.position.x - getSizeFromImage(love.graphics.newImage("assets/export/steak_cooked.png")).x/2, 
            self.position.y - getSizeFromImage(love.graphics.newImage("assets/export/steak_cooked.png")).y/2, 0, 1, 1)
        end
    end,
    [Item.TYPES.BREAD] = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(IMAGES[Item.TYPES.BREAD], self.position.x - getSizeFromImage(IMAGES[Item.TYPES.BREAD]).x/2, 
        self.position.y - getSizeFromImage(IMAGES[Item.TYPES.BREAD]).y/2, 0, 1, 1)
    end,
}

function ItemObject:draw()
    if self.parent then
        -- Update position before drawing to avoid one-frame rendering at stale coords.
        self.position.x = self.parent.position.x + self.anchor_offset.x + self.local_draw_offset.x
        self.position.y = self.parent.position.y + self.anchor_offset.y + self.local_draw_offset.y
    end

    if draw_dispatcher[self.type] then
        draw_dispatcher[self.type](self)
    else
        Entity.draw(self)
    end

    if DEBUGMODE then
        -- Draw item type text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(self.type, self.position.x - 25, self.position.y - 35)
    end
end

return ItemObject