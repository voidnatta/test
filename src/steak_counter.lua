local Class = require("lib.hump.class")
local Counter = require("src.counter")

local SteakCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)
    end
}

function SteakCounter:draw()
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(1, 1, 0.5, 1)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)

    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

return SteakCounter