local love = require("love")

Timer = require("lib.hump.timer")
local Utils = require("src.utils")
local Vector = require("lib.hump.vector")

local push = require ("lib.push.push")

local Player = require("src.player")
local SteakCounter = require("src.steak_counter")
local BreadCounter = require("src.bread_counter")
local TomatoCounter = require("src.tomato_counter")
local CheeseCounter = require("src.cheese_counter")

local EmptyCounter = require("src.empty_counter")
local PlateCounter = require("src.plate_counter")
local OrderCounter = require("src.order_counter")
local CookingCounter = require("src.cooking_counter")
local SlicingCounter = require("src.slicer_counter")

local Game = {}

local gameWidth, gameHeight = 1440, 1080 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()

windowWidth, windowHeight = windowWidth*.7, windowHeight*.7 --make the window a bit smaller than the screen itself

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

function Game:init()
    love.physics.setMeter(32)
    love.graphics.setFont(love.graphics.newFont(28))
    
    self.world = love.physics.newWorld(0, 0, true)
    self.min_interaction_distance = 170.0
    self.nearest_interactable = {}
    self.distance_to_nearest = math.huge
    self.cash_amount = 50.0

    self.queue_free_list = {} -- store entities to later delete
    self.entities = {}
    self.entities.add_entity = function(self, entity)
        table.insert(self, entity)
        entity:load({world = Game.world, entities = self, game = Game})
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

    self.player = Player(Vector(200, 100), {w = 100, h = 100}, 300)

    local tomato_counter = TomatoCounter(Vector(400, 800), {w = 100, h = 100})
    local steak_counter = SteakCounter(Vector(400, 400), {w = 100, h = 100})
    local bread_counter = BreadCounter(Vector(800, 100), {w = 100, h = 100})
    local cheese_counter = CheeseCounter(Vector(600, 100), {w = 100, h = 100})

    local empty_counter = EmptyCounter(Vector(600, 400), {w = 100, h = 100})
    local empty_counter2 = EmptyCounter(Vector(800, 400), {w = 100, h = 100})
    local plate_counter = PlateCounter(Vector(1000, 400), {w = 100, h = 100})
    local order_counter = OrderCounter(Vector(1400, 400), {w = 100, h = 100})
    local cooking_counter = CookingCounter(Vector(1000, 100), {w = 100, h = 100})
    local slicing_counter = SlicingCounter(Vector(1200, 100), {w = 100, h = 100})

    self.entities:add_entity(self.player)
    self.entities:add_entity(tomato_counter)
    self.entities:add_entity(steak_counter)
    self.entities:add_entity(bread_counter)
    self.entities:add_entity(cheese_counter)

    self.entities:add_entity(empty_counter)
    self.entities:add_entity(empty_counter2)
    self.entities:add_entity(plate_counter)
    self.entities:add_entity(order_counter)
    self.entities:add_entity(cooking_counter)
    self.entities:add_entity(slicing_counter)

    Timer.every(5, function ()
        self:decrease_cash(5.0)
        print("Tax baby")
    end)

    -- credits CoffeeBlack by GrimFrenzy 
    self.background_music = love.audio.newSource("music/CoffeeBlack.ogg", "stream")
    self.background_music:setVolume(0.1)
    self.background_music:play()
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
        if self.distance_to_nearest > self.min_interaction_distance then
            self.nearest_interactable = nil
        end
    end
end

function Game:_interact()
    if self.nearest_interactable then
        if self.distance_to_nearest < self.min_interaction_distance then
            self.nearest_interactable:on_interact(self.player)
        end
    else
        if self.player.drop_item then self.player:drop_item() end
    end
end


function Game:increase_cash(amount)
    self.cash_amount = self.cash_amount + amount
end

function Game:decrease_cash(amount)
    self.cash_amount = self.cash_amount - amount
end

function Game:draw()
    push:start()

    self:_draw_game()

    push:finish()
end

function Game:_draw_game()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end

    if self.distance_to_nearest < self.min_interaction_distance then
        if self.nearest_interactable then
            -- draw text e to interect in nearest counter
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("Press E to interact", 
            self.nearest_interactable.position.x - 150, self.nearest_interactable.position.y - 90.0)
        end
    end

    love.graphics.setColor(1, 1, 1, .95)
    love.graphics.rectangle('fill', 5, 20, 350, 50)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(34))
    love.graphics.print("Cash " .. "$ " .. string.format("%.2f", self.cash_amount), 10, 30)
    
    -- love.graphics.setColor(1, 1, 1, .9)
    -- love.graphics.rectangle('fill', 5, 550, 320, 40)
    
    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print('Memory actually used (in Mb): ' .. string.format("%.2f", collectgarbage('count') / 1000.0) , 10, 560)
end

function Game:keypressed(key)
    if key == 'e' then
        self:_interact()
    end

    if key == 'q' then
        self.player:drop_item()
    end

    if key == 'p' then
        if self.background_music:isPlaying() then
            self.background_music:pause()
        else
            self.background_music:play()
        end
    end
end

function Tprint(tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. Tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

function TableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

return Game