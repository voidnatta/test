local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")

local Entity = Class{
    init = function (self, position)
        self.position = position or Vector(0, 0)
        self.size = Vector(100, 100)
        self.interactable = false
        self.offset = Vector(0, 0)
        self.color = {1, 0, 0, 1}
        self.parent = nil
        self.name = "Entity"
        self.sprite = nil
        self.z_order = 0
    end;
    
    load = function(self, game)
        self.game = game.game
        self.entities = game.entities
        self:set_size_based_on_sprite()

    end;
    
    update = function(self, dt)
        -- to be overridden by subclasses
    end;

    set_size_based_on_sprite = function(self)
        if self.sprite then
            self.size = Vector(self.sprite:getWidth(), self.sprite:getHeight())
        end
    end; 
    
    draw = function(self)
        if self.sprite then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(self.sprite, self.position.x - self.size.x / 2, self.position.y - self.size.y / 2, 0.0, 
            self.size.x / self.sprite:getWidth(), self.size.y / self.sprite:getHeight())
        else
            if not DEBUGMODE then return end
            love.graphics.setColor(self.color)
            love.graphics.rectangle('fill', self.position.x - self.size.x/2, self.position.y - self.size.y/2, self.size.x, self.size.y)
        end
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