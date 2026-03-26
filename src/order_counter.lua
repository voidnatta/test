local love = require("love")

local Class = require("lib.hump.class")
local Counter = require("src.base.counter")
local Item = require("src.item")
local Recipe = require("src.recipe")

local OrderCounter = Class {
    __includes = Counter,
    init = function(self, position, size)
        Counter.init(self, position, size)

        self.name = "Order Counter"
        self.area_radius = 40
        self.interactable = true
        self.color = {0.8, 1, 1, 1}
        self.orders = {
            -- {
            --     recipe_name = Recipe.RECIPES_TYPES.BURGER,
            --     recipe_type = Recipe:get_recipe(Recipe.RECIPES_TYPES.BURGER),
            --     expire_time = 3.0
            -- },
            {
                recipe_name = Recipe.RECIPES_TYPES.CHEESE_SLICE,
                recipe_type = Recipe:get_recipe(Recipe.RECIPES_TYPES.CHEESE_SLICE),
                expire_time = RECIPE_START_EXPIRE_TIME
            },
        }
    end
}

function OrderCounter:load(game)
    Counter.load(self, game)
    self.delivery_success_sound = love.audio.newSource("assets/sfx/Menu2A.wav", "static")
    self.delivery_success_sound:setVolume(0.2)
end

function OrderCounter:update(dt)
    if not self.game.can_get_new_order then
        return
    end

    for i, order in ipairs(self.orders) do
        order.expire_time = order.expire_time - dt
        if order.expire_time <= 0 then
            self.game:apply_penalty(10.0)
            table.remove(self.orders, i)
        end
    end
end

function OrderCounter:on_interact(player)
    if not player:has_item_object() then return end

    if player:get_item_object().type == Item.TYPES.PLATE then
        local item_obj = player:get_item_object()
        item_obj:set_object_parent(self)

        local action_sound = love.audio.newSource("assets/sfx/pop5.ogg", "static")
        action_sound:setVolume(0.2)
        action_sound:setPitch(0.8)
        action_sound:play()

        local order_finished = false
        for i, order in ipairs(self.orders) do
            local result = Recipe:try_craft(item_obj.items)

            if result then
                if result == order.recipe_name then
                    -- print("A order has finished ", result)
                    table.remove(self.orders, i)
                    local min_reward = 8.5
                    local max_reward = 19.4
                    local reward = min_reward + math.random() * (max_reward - min_reward)
                    self.game:increase_cash(reward)
                    if self.delivery_success_sound then
                        self.delivery_success_sound:stop()
                        self.delivery_success_sound:play()
                        self.game.can_get_new_order = true
                        self.game:start_spawning_order()
                    end
                    order_finished = true
                    break
                end
            end
        end

        if not order_finished then
           self.game:apply_penalty(5.0)
        end

        item_obj:queue_free()
        item_obj:set_object_parent(nil)
    end
end

function OrderCounter:draw()
    Counter.draw(self)
end

return OrderCounter