local love = require("love")

local Class = require("lib.hump.class")
local Counter = require("src.base.counter")
local Item = require("src.item")
local Recipe = require("src.recipe")

local img_slicer_counter = love.graphics.newImage("assets/export/slicer_counter.png")

local SlicerCounter = Class {
    __includes = Counter,
    init = function(self, position)
        Counter.init(self, position)

        self.name = "Slicer Counter"
        self.area_radius = 40
        self.interactable = true
        self.color = {1, 1, 0, 1}
        self.is_slicing = false
        self.slicing_time = 1.0
        self.slicing_timer = 0.0
    end
}

function SlicerCounter:on_interact(player)
    if self.is_slicing then
        print("Still slicing...")
        return
    end

    if player:has_item_object() and not self:has_item_object() then
        local item_obj = player:get_item_object()

        if item_obj:can_be_contained() then
            item_obj:set_object_parent(self)
            self.is_slicing = true
            self.slicing_timer = self.slicing_time
            -- play slicing sound
            local slicing_sound = love.audio.newSource("assets/sfx/qubodupItemHandling1.wav", "static")
            slicing_sound:setVolume(0.5)
            slicing_sound:play()

            Timer.after(self.slicing_time, function ()
                item_obj.state.sliced = true
                self.is_slicing = false
                self.slicing_timer = 0.0
            end)
        else
            if #item_obj.items == 1 then
                item_obj:set_object_parent(self)
                self.is_slicing = true
                self.slicing_timer = self.slicing_time

                local slicing_sound = love.audio.newSource("assets/sfx/qubodupItemHandling1.wav", "static")
                slicing_sound:setVolume(0.5)
                slicing_sound:play()
                
                Timer.after(self.slicing_time, function ()
                    item_obj.items[1].state.sliced = true
                    self.is_slicing = false
                    self.slicing_timer = 0.0
                end)
            else
                print("Only one item to be able to cook with plate")
            end
        end

    elseif self:has_item_object() then
        if player:has_item_object() then
            if player:get_item_object():is_container() then
                if player:get_item_object():has_space() and
                self:get_item_object().type ~= Item.TYPES.PLATE then
                    player:get_item_object():place_item({
                        type = self:get_item_object().type,
                        state = self:get_item_object().state
                    })

                    self:get_item_object():set_object_parent(nil)
                    self:get_item_object():queue_free()
                end
                return
            else
                print("Player is holding an item that cannot contain sliced items.")
                return
            end
        end
        
        self:get_item_object():set_object_parent(player)

        local slicing_sound = love.audio.newSource("assets/sfx/qubodupItemHandling1.wav", "static")
        slicing_sound:setVolume(0.5)
        slicing_sound:setPitch(0.7)
        slicing_sound:play()
    else
        print("Nothing to slice")
    end
end

function SlicerCounter:update(dt) 
    if self.is_slicing then
        self.slicing_timer = self.slicing_timer - dt
    end
end

function SlicerCounter:draw()
    Counter.draw(self)

    if self.is_slicing then
        love.graphics.setColor(1, 0, 0, 1)
        local normalized_time = self.slicing_timer / self.slicing_time
        love.graphics.rectangle('fill', self.position.x - self.size.x/2, (self.position.y - self.size.y/2) - 30, normalized_time * 100, 10)
    end
end

return SlicerCounter