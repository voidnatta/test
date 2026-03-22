local love = require("love")

local Utils = require("src.utils")
local Timer = require("lib.hump.timer")
local Vector = require("lib.hump.vector")

local Player = require("src.player")
local SteakCounter = require("src.steak_counter")
local EmptyCounter = require("src.empty_counter")
local PlateCounter = require("src.plate_counter")
local OrderCounter = require("src.order_counter")
local BreadCounter = require("src.bread_counter")

local Item = require("src.item")

local Game = {}

function Game:init()
    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 0, true)
    love.graphics.setFont(love.graphics.newFont(18))

    self.queue_free_list = {} -- store entities to later delete
    self.entities = {}
    self.entities.add_entity = function(self, entity)
        table.insert(self, entity)
        entity:load({world = Game.world, entities = self})
    end
    self.entities.add_to_queue_free_list = function(self, entity)
        table.insert(Game.queue_free_list, entity)
    end
    self.entities.queue_free_list_update = function(self)
        if #Game.queue_free_list == 0 then
            return
        end

        -- destroy queued entities first, then remove from active list
        for _, qe in ipairs(Game.queue_free_list) do
            if qe.destroy then
                qe:destroy()
            end

            for i, e in ipairs(self) do
                if e == qe then
                    table.remove(self, i)
                    break
                end
            end
        end

        -- clear the queue
        Game.queue_free_list = {}
    end

    self.nearest_interactable = {}
    self.distance_to_nearest = math.huge

    self.player = Player(Vector(100, 50), {w = 30, h = 30}, 300)
    
    local steak_counter = SteakCounter(Vector(200, 200), {w = 40, h = 40})
    local empty_counter = EmptyCounter(Vector(300, 200), {w = 40, h = 40})
    local empty_counter2 = EmptyCounter(Vector(400, 200), {w = 40, h = 40})
    local bread_counter = BreadCounter(Vector(400, 50), {w = 40, h = 40})
    local plate_counter = PlateCounter(Vector(500, 200), {w = 40, h = 40})
    local order_counter = OrderCounter(Vector(700, 200), {w = 40, h = 40})

    self.entities:add_entity(self.player)
    self.entities:add_entity(steak_counter)
    self.entities:add_entity(empty_counter)
    self.entities:add_entity(empty_counter2)
    self.entities:add_entity(bread_counter)
    self.entities:add_entity(plate_counter)
    self.entities:add_entity(order_counter)
end

function Game:update(dt)
    Timer.update(dt)

    Game:_handle_interaction()

    if Utils.gamepad_button_pressed('a') then
        self:_interact()
    end

    if Utils.gamepad_button_pressed('y') then
        if self.player.drop_item then self.player:drop_item() end
    end

    Utils.update()
    
    self.world:update(dt)
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
    self.entities:queue_free_list_update()
end

function Game:_handle_interaction()
    local interactables = {}

    for _, entity in ipairs(self.entities) do
        if entity.interactable then
            table.insert(interactables, entity)
        end
    end
    
    table.sort(interactables, function(a, b)
        local ax, ay = a.position.x, a.position.y
        local bx, by = b.position.x, b.position.y
        local px, py = self.player.position.x, self.player.position.y

        local distance_a = math.sqrt((ax - px)^2 + (ay - py)^2)
        local distance_b = math.sqrt((bx - px)^2 + (by - py)^2)

        return distance_a < distance_b
    end)

    self.nearest_interactable = interactables[1] or nil
    if self.nearest_interactable then
        self.distance_to_nearest = math.sqrt(
        (self.nearest_interactable.position.x - self.player.position.x)^2 + 
        (self.nearest_interactable.position.y - self.player.position.y)^2)
        if self.distance_to_nearest > 75.0 then
            self.nearest_interactable = nil
        end
    end
end

function Game:_interact()
    if self.nearest_interactable then
        if self.distance_to_nearest < 75.0 then
            self.nearest_interactable:on_interact(self.player)
        end
    else
        if self.player.drop_item then self.player:drop_item() end
    end
end

function Game:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end

    if self.distance_to_nearest < 75.0 then
        if self.nearest_interactable then
            -- draw text e to interect in nearest counter
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("Press E to interact", 
            self.nearest_interactable.position.x - 75, self.nearest_interactable.position.y - 50)
        end
    end

    love.graphics.setColor(1, 1, 1, .9)
    love.graphics.rectangle('fill', 5, 60, 120, 30)
    
    local score_calculated = 0
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Score " .. score_calculated, 10, 60)
    
    love.graphics.setColor(1, 1, 1, .9)
    love.graphics.rectangle('fill', 5, 10, 320, 30)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print('Memory actually used (in Mb): ' .. string.format("%.2f", collectgarbage('count') / 1000.0) , 10, 10)
end

function Game:keypressed(key)
    if key == 'e' then
        self:_interact()
    end

    if key == 'q' then
        self.player:drop_item()
    end
end

return Game