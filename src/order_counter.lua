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
            Recipe.RECIPES_TYPES.BURGER,
            Recipe.RECIPES_TYPES.TOMATO_CHEESE,
            Recipe.RECIPES_TYPES.SLICED_TOMATO,
        }
    end
}

function OrderCounter:load(game)
    Counter.load(self, game)

    Timer.every(8.0, function ()
        if #self.orders >= 3  then
            return
        end

        local recipes = Recipe:get_recipes()
        
        local keyset = {}
        for k in pairs(recipes) do
            table.insert(keyset, k)
        end

        local random_recipe = keyset[math.random(#keyset)]
        self.orders[#self.orders+1] = random_recipe
    end)

end

function OrderCounter:on_interact(player)
    if not player:has_item_object() then return end

    if player:get_item_object().type == Item.TYPES.PLATE then
        local item_obj = player:get_item_object()
        item_obj:set_object_parent(self)

        -- print(item_obj.name)
        -- print(Tprint(item_obj.items))

        for i, order in ipairs(self.orders) do
            local result = Recipe:try_craft(item_obj.items)

            if result then
                if result == order then
                    -- print("A order has finished ", result)
                    table.remove(self.orders, i)
                    self.game:increase_cash(20.0)
                end
            end
        end

        item_obj:queue_free()
        item_obj:set_object_parent(nil)
    end
end

function OrderCounter:draw()
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)
    
    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x + self.size.w/2, position_y + self.size.h/2, self.area_radius)
end

return OrderCounter