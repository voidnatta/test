local love = require("love")

local Class = require("lib.hump.class")
local ItemObject = require("src.item_object")
local Item = require("src.item")

local PlateObject = Class{
    __includes = ItemObject,
    init = function(self, position, size)
        ItemObject.init(self, position, size, Item.TYPES.PLATE)
        self.items = {}
        self.max_items = 5
        self.color = {0.8, 0.8, 0.8, 1} -- Light gray
    end
}

function PlateObject:draw()
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

    for i, item in ipairs(self.items) do
        love.graphics.print(item.type, self.position.x - 20, self.position.y - 15 + (i-1)*20)
    end
end

return PlateObject