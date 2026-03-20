local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Entity = Class{
    init = function (self, position, size)
        self.position = position or Vector(0, 0)
        self.size = size or Vector(100, 100)
    end,
    load = function(self)
        -- to be overridden by subclasses
    end,
    update = function(self, dt)
        -- to be overridden by subclasses
    end,
    draw = function(self)
        -- to be overridden by subclasses
    end,
}

return Entity