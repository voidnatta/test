local love = require("love")

local GameState = require("lib.hump.gamestate")

local counter = require("src.counter")
local item = require("src.item")

-- scenes
local Game = require("scenes.game")

local world

local entities = {}
local nearest_interactable = nil
local distance_to_nearest = math.huge
local finish_counter
local player1

function love.load()
    GameState.registerEvents()
    GameState.switch(Game)

    if true then return end

    -- timer.tween(2, player1, {size = {w = 100, h = 100}}, 'in-out-cubic', function() 
    --     timer.tween(2, player1, {size = {w = 30, h = 30}}, 'in-out-cubic')
    -- end)

    -- gets a steak from the tomato counter and puts it in the player's hand when interacted with
    -- local steak_counter = counter:new({x = 200, y = 50}, {w = 30, h = 30})
    -- steak_counter.on_interact = function(self, _player)
    --     if _player.item_holding then
    --         return
    --     end
        
    --     local new_item = item:new({x = _player.position.x, 
    --     y = _player.position.y - _player.size.h/2 - 20}, {w = 20, h = 20}, "steak")
    --     new_item.offset = {x = 0, y = -_player.size.h/2 - 20}
    --     _player.item_holding = new_item
    --     new_item:load(utils, world)
    --     new_item.parent = _player
    --     new_item.color = {1, 0.5, 0, 1}

    --     table.insert(entities, new_item)
    -- end

    -- gets a tomato from the tomato counter and puts it in the player's hand when interacted with
    -- local tomato_counter = counter:new({x = 200, y = 230}, {w = 30, h = 30}, "tomato")
    -- tomato_counter.on_interact = function(self, _player)
    --     if _player.item_holding then
    --         return
    --     end
        
    --     local new_item = item:new({x = _player.position.x, 
    --     y = _player.position.y - _player.size.h/2 - 20}, {w = 20, h = 20})
    --     new_item.offset = {x = 0, y = -_player.size.h/2 - 20}
    --     _player.item_holding = new_item
    --     new_item:load(utils, world)
    --     new_item.parent = _player
    --     new_item.color = {1, 1.0, 0, 1}

    --     table.insert(entities, new_item)
    -- end

    -- table used to cut tomato or steak, if the player interacts with this counter while holding an item
    -- the item becomes sliced
    -- local cutting_board = counter:new({x = 400, y = 50}, {w = 30, h = 30})
    -- cutting_board.on_interact = function(self, _player)
    --     if not _player.item_holding == nil then
    --         return
    --     end
    --     if _player.item_holding then
    --         if _player.item_holding.cooked then return end
    --     end

    --     if _player.item_holding then
    --         _player.item_holding.color = {0, 1, 0, 1}
    --         _player.item_holding.sliced = true
    --         _player.item_holding.type = "sliced_" .. _player.item_holding.type
    --     end
    -- end

    -- cooking counter, if the player interacts with this counter while holding an item,
    -- the item is placed on the counter and after x second it becomes cooked
--     local cooking_counter = counter:new({x = 600, y = 50}, {w = 30, h = 30})
--     cooking_counter.item_cooking = nil
--     cooking_counter.cook_time = 1.0
--     cooking_counter.overcooked = false
--     cooking_counter.on_interact = function(self, _player)
--         if self.item_cooking then
--             if not self.item_cooking.sliced then return end
--             if not self.item_cooking.cooked then return end
--             if _player.item_holding then return end

--             _player.item_holding = self.item_cooking
--             self.item_cooking.parent = _player
--             self.item_cooking.interactable = false
--             self.item_cooking.offset = {
--                 x = 0,
--                 y = -_player.size.h/2 - 20
--             }
--             if self.overcooked then
--                 _player.item_holding.type = "overcooked_" .. _player.item_holding.type
--             else
--                 _player.item_holding.type = "cooked_" .. _player.item_holding.type
--             end
--             self.item_cooking = nil
--             return
--         end

--         if _player.item_holding == nil then
--             return
--         end

--         if _player.item_holding.cooked then
--             return
--         end

--         self.item_cooking = _player.item_holding
--         self.item_cooked = false
--         self.overcooked = false
--         self.cook_time = 1.0

--         _player.item_holding.parent = self
--         _player.item_holding.interactable = false
--         _player.item_holding.offset = {
--             x = self.size.w/2 - _player.item_holding.size.w/2,
--             y = self.size.h/2 - _player.item_holding.size.h/2
--         }
--         _player.item_holding = nil
--     end
-- ---@diagnostic disable-next-line: duplicate-set-field
--     cooking_counter.update = function(self, dt)
--         if self.item_cooking then
--             self.cook_time = self.cook_time - dt
--             if self.cook_time <= 0 then
--                 self.item_cooking.color = {0, 0, 1, 1}
--                 self.item_cooking.cooked = true
--             end if self.cook_time < -5 then
--                 -- overcooked
--                 self.item_cooking.color = {0.2, 0, 0, 1}
--                 self.overcooked = true
--             end
--         end
--     end

    -- the last counter, if the player interacts with this counter while holding a finished item, 
    -- the item is placed on the counter and after x second it is removed from the game and the
    -- player gets a point
--     finish_counter = counter:new({x = 600, y = 230}, {w = 30, h = 30})
--     finish_counter.items_served = 0
--     finish_counter.items_being_moved = {}
--     finish_counter.on_interact = function(self, _player)
--         -- check if player is holding an item, its cooked
--         -- if so, the item becomes parent of this counter and is no longer interactable
--         if _player.item_holding == nil then
--             return
--         end

--         if not _player.item_holding.cooked then
--             return
--         end

--         _player.item_holding.parent = nil
--         _player.item_holding.interactable = false
--         _player.item_holding.position.x = self.position.x + self.size.w/2 - _player.item_holding.size.w/2
--         _player.item_holding.position.y = self.position.y + self.size.h/2 - _player.item_holding.size.h/2
--         _player.item_holding.offset = {
--             x = self.size.w/2 - _player.item_holding.size.w/2,
--             y = self.size.h/2 - _player.item_holding.size.h/2
--         }
--         table.insert(self.items_being_moved, {item = _player.item_holding, time_to_remove = 1.0})
--         self.items_served = self.items_served + 1
        
--         _player.item_holding = nil

--     end
-- ---@diagnostic disable-next-line: duplicate-set-field
--     finish_counter.update = function(self, dt)
--         for _, item_data in ipairs(self.items_being_moved) do
--             item_data.item.position.x = item_data.item.position.x + 50 * dt
--             item_data.time_to_remove = item_data.time_to_remove - dt
--             if item_data.time_to_remove <= 0 then
--                 table.remove(self.items_being_moved)
--                 -- remove item from entities list
--                 for j, entity in ipairs(entities) do
--                     if entity == item_data.item then
--                         table.remove(entities, j)
--                         break
--                     end
--                 end
--             end
--         end
--     end

--     table.insert(entities, player1)
--     table.insert(entities, tomato_counter)
--     table.insert(entities, steak_counter)
--     table.insert(entities, cutting_board)
--     table.insert(entities, cooking_counter)
--     table.insert(entities, finish_counter)
end

function love.update(dt)
    if true then return end

    -- local interactables = {}

    -- for _, entity in ipairs(entities) do
    --     if entity.interactable then
    --         table.insert(interactables, entity)
    --     end
    -- end
    
    -- table.sort(interactables, function(a, b)
    --     local ax, ay = a.position.x, a.position.y
    --     local bx, by = b.position.x, b.position.y
    --     local px, py = player1.position.x, player1.position.y

    --     local distance_a = math.sqrt((ax - px)^2 + (ay - py)^2)
    --     local distance_b = math.sqrt((bx - px)^2 + (by - py)^2)

    --     return distance_a < distance_b
    -- end)

    -- nearest_interactable = interactables[1] or nil
    -- if nearest_interactable then
    --     distance_to_nearest = math.sqrt(
    --     (nearest_interactable.position.x - player1.position.x)^2 + 
    --     (nearest_interactable.position.y - player1.position.y)^2)
    --     if distance_to_nearest > 75.0 then
    --         nearest_interactable = nil
    --     end
    -- end

    -- if utils.gamepad_button_pressed('a') then
    --     interact()
    -- end

    -- if utils.gamepad_button_pressed('y') then
    --     player1:drop_item(entities)
    -- end
end

-- function love.keypressed(key)
--     if key == 'e' then
--         interact()
--     end

--     if key == 'q' then
--         player1:drop_item()
--     end
-- end

-- function interact()
--     if nearest_interactable then
--         if distance_to_nearest < 75.0 then
--             if nearest_interactable.on_interact then
--                 nearest_interactable:on_interact(player1)
--             end
--         end
--     else
--         player1:drop_item()
--     end
-- end

function love.draw()
    if true then return end

    -- if distance_to_nearest < 75.0 then
    --     if nearest_interactable then
    --         -- draw text e to interect in nearest counter
    --         love.graphics.setColor(1, 1, 1, 1)
    --         love.graphics.print("Press E to interact", 
    --         nearest_interactable.position.x - 40, nearest_interactable.position.y - 20)
    --     end
    -- end
    
    -- love.graphics.setColor(1, 1, 1, .9)
    -- love.graphics.rectangle('fill', 5, 5, 120, 30)
    
    -- local score_calculated = finish_counter.items_served * 10
    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print("Score " .. score_calculated, 10, 10)
end