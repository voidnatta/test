local love = require("love")

local Class = require("lib.hump.class")
local DynamicEntity = require("src.dynamic_entity")

local Counter = Class {
    __includes = DynamicEntity,
    init = function(self, position, size)
        DynamicEntity.init(self, position, size, "static")

        self.area_radius = 40
        self.interactable = true
    end,
    interact = function(self, player)
        -- to be overridden by subclasses
    end
}

function Counter:draw()
    -- local position_x, position_y = self.body:getPosition()
    -- love.graphics.setColor(1, 0.5, 0.5, 1)
    -- love.graphics.rectangle('fill', position_x, position_y, self.size.w, self.size.h)
    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x + self.size.w/2, position_y + self.size.h/2, self.area_radius)
end

return Counter

-- function counter:new(position, size)
--     local obj = entity:new(position, size)

--     obj.body = {}
--     obj.shape = {}
--     obj.fixture = nil
--     obj.area_radius = 40
--     obj.interactable = true

--     return setmetatable(obj, counter)
-- end

-- function counter:load(_utils, _world)
--     utils = _utils
--     world = _world
-- end

-- function counter:update(dt)
--     -- no movement for static counter, keep this hook here
-- end

-- function counter:draw()

-- end

-- return counter