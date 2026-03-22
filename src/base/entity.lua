local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Entity = Class{
    init = function (self, position, size)
        self.position = position or Vector(0, 0)
        self.size = size or Vector(100, 100)
        self.interactable = false
        self.offset = Vector(0, 0)
        self.color = {1, 0, 0, 1}
        self.parent = nil
        self.name = "Entity"
    end;
    
    load = function(self, game)
        self.entities = game.entities
    end;
    
    update = function(self, dt)
        -- to be overridden by subclasses
    end;
    
    draw = function(self)
        -- to be overridden by subclasses
    end;

    on_interact = function(self, player)
        -- to be overridden by subclasses
    end;

    destroy = function(self)
        -- no physics cleanup for base entity
        self.entities = nil
        self.parent = nil
    end;

    queue_free = function(self)
        if self.entities then
            self.entities:add_to_queue_free_list(self)
        else
            print("Warning: Entity does not have reference to entities list. Cannot queue free.")
        end
    end
}

return Entity