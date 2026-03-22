local love = require("love")

local Class = require("lib.hump.class")
local Counter = require("src.base.counter")
local Item = require("src.item")
local Recipe = require("src.recipe")

local CookingCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)

        self.name = "Cooking Counter"
        self.area_radius = 40
        self.interactable = true
        self.color = {1, 1, 0, 1}
        self.is_cooking = false
        self.cooking_time = 3.0
        self.cooking_timer = 0.0
    end
}

function CookingCounter:on_interact(player)
    if self.is_cooking then
        print("Still cooking...")
        return
    end

    if player:has_item_object() then
        local item_obj = player:get_item_object()

        if item_obj:can_be_contained() then
            item_obj:set_object_parent(self)
            self.is_cooking = true
            self.cooking_timer = 3.0

            Timer.after(self.cooking_time, function ()
                item_obj.state.cooked = true
                self.is_cooking = false
                self.cooking_timer = 0.0
            end)
        else
            if #item_obj.items == 1 then
                item_obj:set_object_parent(self)
                self.is_cooking = true
                self.cooking_timer = 3.0
                
                Timer.after(self.cooking_time, function ()
                    item_obj.items[1].state.cooked = true
                    self.is_cooking = false
                    self.cooking_timer = 0.0
                end)
            else
                print("Only one item to be able to cook with plate")
            end
        end

    elseif self:has_item_object() then
        self:get_item_object():set_object_parent(player)
    else
        print("Nothing to cook")
    end
end

function CookingCounter:update(dt) 
    if self.is_cooking then
        self.cooking_timer = self.cooking_timer - dt
    end
end

function CookingCounter:draw()
    Counter.draw(self)

    if self.is_cooking then
        love.graphics.setColor(1, 0, 0, 1)
        local normalized_time = self.cooking_timer / self.cooking_time
        love.graphics.rectangle('fill', position_x - self.size.w/2, (position_y - self.size.h/2) - 30, normalized_time * 100, 10)
    end
end

return CookingCounter