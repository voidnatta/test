local love = require("love")
local entity = require("src.entity")

local item = {}
item.__index = item

local utils, world

function item:new(position, size, type)
    local obj = entity:new(position, size)

    obj.interactable = false
    obj.offset = {x = 0, y = 0}
    obj.color = {1, 0, 0, 1}
    obj.sliced = false
    obj.cooked = false
    obj.type = type or "tomato"

    return setmetatable(obj, item)
end

function item:load(_utils, _world)
    utils = _utils
    world = _world
end

function item:update(dt)
    
end

function item:on_interact(player)
    print(self.type .. " interacted with player")
    if player.item_holding then
        return
    end

    -- only allow interaction if the item is not currently held by a player
    if self.interactable and not self.parent then
        player.item_holding = self
        self.parent = player
        self.interactable = false
    end
end

function item:draw()
    if self.parent then
        local parent_x, parent_y = self.parent.position.x, self.parent.position.y
        self.position.x = parent_x + self.offset.x
        self.position.y = parent_y + self.offset.y
    end
    
    local position_x, position_y = self.position.x, self.position.y
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', position_x, position_y, self.size.w, self.size.h)
end

return item