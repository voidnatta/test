local love = require("love")

local Class = require("lib.hump.class")
local ItemObject = require("src.item_object")
local Item = require("src.item")

local PLATE_ITEM_IMAGES = {
    bread_bottom = love.graphics.newImage("assets/export/bread_bottom.png"),
    bread_top = love.graphics.newImage("assets/export/bread_top.png"),
    tomato = love.graphics.newImage("assets/export/tomato.png"),
    tomato_sliced = love.graphics.newImage("assets/export/cutted_tomato.png"),
    cheese = love.graphics.newImage("assets/export/cheese.png"),
    steak = love.graphics.newImage("assets/export/steak.png"),
    steak_cooked = love.graphics.newImage("assets/export/steak_cooked.png")
}

local PlateObject = Class{
    __includes = ItemObject,
    init = function(self, position)
        ItemObject.init(self, position, Item.TYPES.PLATE)
        self.items = {}
        self.max_items = 6
        self.color = {0.8, 0.8, 0.8, 1} -- Light gray
    end
}

local function get_plate_layer_image(layer)
    if layer.kind == "bread_bottom" then
        return PLATE_ITEM_IMAGES.bread_bottom
    end

    if layer.kind == "bread_top" then
        return PLATE_ITEM_IMAGES.bread_top
    end

    if layer.type == Item.TYPES.TOMATO then
        if layer.state and layer.state.sliced then
            return PLATE_ITEM_IMAGES.tomato_sliced
        end
        return PLATE_ITEM_IMAGES.tomato
    end

    if layer.type == Item.TYPES.CHEESE then
        return PLATE_ITEM_IMAGES.cheese
    end

    if layer.type == Item.TYPES.STEAK then
        if layer.state and layer.state.cooked then
            return PLATE_ITEM_IMAGES.steak_cooked
        end
        return PLATE_ITEM_IMAGES.steak
    end

    return nil
end

local function build_plate_layers(items)
    local layers = {}
    local bread_count = 0

    for _, item in ipairs(items) do
        if item.type == Item.TYPES.BREAD then
            bread_count = bread_count + 1
        end
    end

    if bread_count > 0 then
        table.insert(layers, {kind = "bread_bottom"})
    end

    for _, item in ipairs(items) do
        if item.type ~= Item.TYPES.BREAD then
            table.insert(layers, item)
        end
    end

    if bread_count > 1 then
        table.insert(layers, {kind = "bread_top"})
    end

    return layers
end

function PlateObject:has_space()
    return #self.items < self.max_items
end

function PlateObject:place_item(item)
    if item == nil then return end

    if self:has_space() then
        table.insert(self.items, item)
        
        local action_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:play()

        return true
    end
    return false
end

function PlateObject:draw()
    ItemObject.draw(self)

    local layers = build_plate_layers(self.items)

    for i, layer in ipairs(layers) do
        local offset = 5.0
        if layer.kind == "bread_top" then
            offset = 8.0
        end
        local image = get_plate_layer_image(layer)
        if image then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                image,
                self.position.x - image:getWidth() / 2,
            (self.position.y - image:getHeight() / 2) - (i - 1) * offset) -- Stack layers with a small offset
        end
    end

    for i = 0, #self.items do
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle('fill', self.position.x + 25, self.position.y - 10, 50, 45, 10, 10)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(#self.items .. "/" .. self.max_items, self.position.x, self.position.y, 100, "center")
    end 
end

return PlateObject