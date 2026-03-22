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
            {Item.TYPES.BURGER},
            {Item.TYPES.COOKED_STEAK},
        }
    end
}

function OrderCounter:on_interact(player)
    if not player:has_item_object() then return end

    if player:get_item_object().type == Item.TYPES.PLATE then
        local item_obj = player:get_item_object()
        item_obj:set_object_parent(self)

        for i, order in ipairs(self.orders) do
            local result = Recipe:try_craft(item_obj.items)
            
            if result then
                if result == order[1] then
                    print("A order has finished ", result)
                    table.remove(self.orders, i)
                end
            end
        end

        item_obj:queue_free()
        item_obj:set_object_parent(nil)
    end
    -- if self:has_item_object() and player:has_item_object() then
    --     local a = player:get_item_object()
    --     local b = self:get_item_object()

    --     local container = nil
    --     local content = nil

    --     if a:is_container() and b:can_be_contained() then
    --         container = a
    --         content = b
    --     elseif b:is_container() and a:can_be_contained() then
    --         container = b
    --         content = a
    --     else 
    --         return
    --     end

    --     if container.items and #container.items <= container.max_items then
    --         table.insert(container.items, {
    --             type = content.type,
    --             state = container.state
    --         })

    --         local result = Recipe:try_craft(container.items)
    --         if result then
    --             container.items = {
    --                 {type = result}
    --             }
    --         end
    --         print(result)

    --         content:queue_free()
    --         content:set_object_parent(nil)
    --     else
    --         print("Container is not empty")
    --     end

    --     -- container:set_object_parent(player)
    --     return
    -- end

    -- if player:has_item_object() then
    --     local item_obj = player:get_item_object()
    --     item_obj:set_object_parent(self)
    -- elseif self:has_item_object() then
    --     self:get_item_object():set_object_parent(player)
    -- else
    --     print("Nothing happens")
    -- end
end

function OrderCounter:draw()
    local position_x, position_y = self.body:getPosition()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', position_x - self.size.w/2, position_y - self.size.h/2, self.size.w, self.size.h)
    
    -- love.graphics.setColor(1, 0.5, 0.5, 0.2)
    -- love.graphics.circle('fill', position_x + self.size.w/2, position_y + self.size.h/2, self.area_radius)
end

return OrderCounter


-- local action_type_handler = {
--     [Item.TYPES.PLATE] = function(self, player)
--         print("EmptyCounter is holding a plate. Cannot place on counter.")
--     end,
--     [Item.TYPES.STEAK] = function(self, player)
--         local player_item = player:get_item_object()
--         if player_item.type == Item.TYPES.PLATE then
--             if player_item.items and #player_item.items == 0 then
--                 player_item.items[#player_item.items + 1] = Item.TYPES.STEAK
--                 self:get_item_object():queue_free()
--                 self:get_item_object():set_object_parent(nil)
--             else
--                 print("Player is holding a plate, but it's not empty. Cannot place on counter.")
--             end
--         end
--     end
-- }