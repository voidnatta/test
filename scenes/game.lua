local love = require("love")

DEBUGMODE = false
DESIGNMODE = false

GAME_WIDTH, GAME_HEIGHT = 1440, 1080 --fixed game resolution
WINDOW_WIDTH, WINDOW_HEIGHT = 1440, 1080
LEVEL_DESIGN_MOVE_SPEED = 200
MIN_INTERACTION_DISTANCE = 270.0
DAY_DURATION_SECONDS = 100
RECIPE_START_EXPIRE_TIME = 35.0

WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH*.7, WINDOW_HEIGHT*.7

Timer = require("lib.hump.timer")
Push = require ("lib.push.push")

local Vector = require("lib.hump.vector")
local Utils = require("src.utils")

local Entities = require("src.systems.entities")
local DesignMode = require("src.debug.designmode")
local assets = require("src.assets")
local mobile_joystick = require("src.gui.mobile_joystick")

local game_gui = require("src.gui.game_gui")

-- Scenes
local DayEnd = require("scenes.day_end")

-- Entities
local Entity = require("src.base.entity")
local DynamicEntity = require("src.dynamic_entity")
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

local Recipe = require("src.recipe")

local Game = {}

Push:setupScreen(GAME_WIDTH, GAME_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false, resizable = false, vsync = true})

local function lerp(current, target, t)
    return current + (target - current) * t
end

function Game:init(initial_state)
    love.physics.setMeter(32)
    love.graphics.setFont(love.graphics.newFont(34))

    
    self.world = love.physics.newWorld(0, 0, true)
    self.entities = Entities.new(self, self.world)
    self.designmode = DesignMode.new(self)

    self.nearest_interactable = {}
    self.distance_to_nearest = math.huge
    self.interact_prompt = {
        x = GAME_WIDTH / 2,
        y = GAME_HEIGHT / 2,
        alpha = 0.0,
        width = 48,
        height = 48,
        corner_radius = 8,
        font = love.graphics.newFont(32),
        position_lerp_speed = 20.0,
        alpha_lerp_speed = 15.0
    }

    self.day_number = (initial_state and initial_state.day_number) or 1
    self.cash_amount = (initial_state and initial_state.cash_amount) or 50.0
    self.day_duration = DAY_DURATION_SECONDS
    self.day_time_left = self.day_duration
    self.day_transitioning = false
    self.order_spawn_timer = 12.0
    self.recipe_expire_time = RECIPE_START_EXPIRE_TIME
    self.can_get_new_order = false
    self.show_play_screen = false
    self.paused = false

    game_gui:load(self)
    
    self:_spawn_game_entities()

    self.order_spawn_timer = self:_get_order_spawn_interval()
end

function Game:enter(_previous_state, state)
    if not state then
        return
    end
    
    if state.show_play_screen then
        self.show_play_screen = true
        self.paused = true
        return
    end

    if not state.should_reset and not state.next_day_state then
        return
    end

    -- Reset all scheduled callbacks from the previous run before rebuilding state.
    Timer.clear()

    if state.should_reset then
        self:init()
        return
    end

    self:init(state.next_day_state)
end

function Game:start_the_game()
    self.paused = false
    -- self.show_play_screen = false
    Timer.tween(0.7, game_gui, {background_alpha = 0.0}, 'out-cubic')
    Timer.tween(0.7, game_gui.play_button, {y = GAME_HEIGHT + 200}, 'out-cubic', function ()
        self.show_play_screen = false
    end)
    Timer.tween(0.7, game_gui.day_gui, {y = 20}, 'out-cubic')
    Timer.tween(0.7, game_gui.order_gui_offset, {y = 20}, 'out-cubic')
end

function Game:_spawn_game_entities()
    self.player = Player(Vector(GAME_WIDTH / 2, (GAME_HEIGHT / 2) + 100.0), 600)

    local tomato_counter = TomatoCounter(Vector(1199.00, 988.00), {w = 152, h = 165})
    tomato_counter.sprite = assets.IMAGES.img_tomato_counter
    tomato_counter.z_order = 4

    local empty_counter = EmptyCounter(Vector(945, 302), {w = 152, h = 250})
    empty_counter.sprite = assets.IMAGES.img_empty_counter
    empty_counter.item_anchor_offset = Vector(0, -39)
    empty_counter.custom_shape_size = Vector(100, 10)

    local empty_counter_bottom = EmptyCounter(Vector(857.00, 1007.00), {w = 152, h = 250})
    -- empty_counter_bottom.placement_offset = Vector(0, -70)
    -- empty_counter_bottom.interact_gui_offset = Vector(-30, -35)
    
    local empty_counter_bottom2 = EmptyCounter(Vector(347.00, 1007.00), {w = 152, h = 250})
    empty_counter_bottom2.placement_offset = Vector(0, -70)
    -- empty_counter_bottom2.interact_gui_offset = Vector(-30, 25)
    
    local empty_counter_bottom3 = EmptyCounter(Vector(688.00, 1007.00), {w = 152, h = 250})
    empty_counter_bottom3.placement_offset = Vector(0, -70)

    local slicing_counter = SlicingCounter(Vector(664.00, 304), {w = 152, h = 250})
    slicing_counter.sprite = assets.IMAGES.img_slicer_counter
    slicing_counter.item_anchor_offset = Vector(-6, -42)
    slicing_counter.custom_shape_size = Vector(100, 10)

    local plate_counter = PlateCounter(Vector(805, 304), {w = 152, h = 250})
    plate_counter.sprite = assets.IMAGES.img_plate_counter
    plate_counter.custom_shape_size = Vector(100, 10)

    local cheese_counter = CheeseCounter(Vector(353, 271), {w = assets.IMAGES.img_cheese_counter:getWidth(), h = assets.IMAGES.img_cheese_counter:getHeight()})
    cheese_counter.sprite = assets.IMAGES.img_cheese_counter
    cheese_counter.custom_shape_size = Vector(100, 10)
    
    local steak_counter = SteakCounter(Vector(508.45, 271), {w = assets.IMAGES.img_steak_counter:getWidth(), h = assets.IMAGES.img_steak_counter:getHeight()})
    steak_counter.sprite = assets.IMAGES.img_steak_counter
    steak_counter.custom_shape_size = Vector(100, 10)

    self.order_counter = OrderCounter(Vector(1090, 350), {w = assets.IMAGES.img_order_counter:getWidth(), h = assets.IMAGES.img_order_counter:getHeight()})
    self.order_counter.sprite = assets.IMAGES.img_order_counter
    self.order_counter.custom_shape_size = Vector(100, 10)
    self.order_counter.offset = Vector(0, -98)
    self.order_counter.interact_gui_offset = Vector(0, -50)

    local left_counter = Entity(Vector(assets.IMAGES.img_left_counter:getWidth() / 2, assets.IMAGES.img_left_counter:getHeight() / 2),
    {w = assets.IMAGES.img_left_counter:getWidth(), h = assets.IMAGES.img_left_counter:getHeight()})
    left_counter.sprite = assets.IMAGES.img_left_counter

    local right_counter = Entity(Vector(719.14, 534.73),
    {w = assets.IMAGES.img_right_counter:getWidth(), h = assets.IMAGES.img_right_counter:getHeight()})
    right_counter.sprite = assets.IMAGES.img_right_counter

    local bottom_counter = Entity(Vector(590, 940),
    {w = assets.IMAGES.img_bottom_counter:getWidth(), h = assets.IMAGES.img_bottom_counter:getHeight()})
    bottom_counter.sprite = assets.IMAGES.img_bottom_counter
    bottom_counter.z_order = 5

    local bread_counter = BreadCounter(Vector(1036.00, 990.00), {w = assets.IMAGES.img_bread_counter:getWidth(), h = assets.IMAGES.img_bread_counter:getHeight()})
    bread_counter.sprite = assets.IMAGES.img_bread_counter
    bread_counter.z_order = 2

    local cooking_counter = CookingCounter(Vector(528.00, 1007.00), {w = assets.IMAGES.img_cook_counter:getWidth(), h = assets.IMAGES.img_cook_counter:getHeight()})
    cooking_counter.sprite = assets.IMAGES.img_cook_counter
    cooking_counter.z_order = 6
    cooking_counter.item_anchor_offset = Vector(0, -2)

    -- collisions
    local bottom_center = DynamicEntity(Vector(GAME_WIDTH / 2, GAME_HEIGHT - 200), "static")
    bottom_center.custom_shape_size = Vector(GAME_WIDTH, 50)

    local left_border = DynamicEntity(Vector(200, GAME_HEIGHT / 2), "static")
    left_border.custom_shape_size = Vector(50, GAME_HEIGHT)

    local right_border = DynamicEntity(Vector(GAME_WIDTH - 200, GAME_HEIGHT / 2), "static")
    right_border.custom_shape_size = Vector(50, GAME_HEIGHT)

    local top_border = DynamicEntity(Vector(GAME_WIDTH / 2, 330), "static")
    top_border.custom_shape_size = Vector(GAME_WIDTH, 50)

    self.entities:add_entity(bottom_center)
    self.entities:add_entity(left_border)
    self.entities:add_entity(right_border)
    self.entities:add_entity(top_border)

    self.entities:add_entity(self.player)
    self.entities:add_entity(tomato_counter)
    self.entities:add_entity(steak_counter)
    self.entities:add_entity(bread_counter)
    self.entities:add_entity(cheese_counter)

    self.entities:add_entity(empty_counter)
    self.entities:add_entity(empty_counter_bottom)
    self.entities:add_entity(empty_counter_bottom2)
    self.entities:add_entity(empty_counter_bottom3)
    self.entities:add_entity(left_counter)
    self.entities:add_entity(right_counter)
    self.entities:add_entity(bottom_counter)

    self.entities:add_entity(plate_counter)
    self.entities:add_entity(self.order_counter)
    self.entities:add_entity(cooking_counter)
    self.entities:add_entity(slicing_counter)
end

function Game:start_spawning_order()
    self.order_spawn_timer = 2.0
end

function Game:_get_order_spawn_interval()
    local base_interval = 12.0
    local day_penalty = (self.day_number - 1) * 0.6
    return math.max(6.0, base_interval - day_penalty)
end

function Game:_spawn_random_order()
    if not self.order_counter then
        return
    end

    if not self.can_get_new_order then
         return
    end

    if #self.order_counter.orders >= 4 then
        local min_reward = 3.0
        local max_reward = 6.0
        local _penalty = min_reward + math.random() * (max_reward - min_reward)

        self:apply_penalty(_penalty)
        return
    end

    local recipes = Recipe:get_recipes()
    local keyset = {}
    for k in pairs(recipes) do
        table.insert(keyset, k)
    end

    local random_recipe = keyset[math.random(#keyset)]
    self.order_counter.orders[#self.order_counter.orders + 1] = {
        recipe_name = random_recipe,
        recipe_type = Recipe:get_recipe(random_recipe),
        expire_time = self.recipe_expire_time
    }
end

function Game:_calculate_day_expenses()
    local operating_cost = 8.0 + (self.day_number - 1) * 2.5
    local tax_rate = math.min(0.22, 0.08 + (self.day_number - 1) * 0.01)
    local tax_amount = math.max(self.cash_amount, 0) * tax_rate
    return operating_cost, tax_amount, operating_cost + tax_amount
end

function Game:_end_day()
    if self.day_transitioning then
        return
    end

    self.day_transitioning = true

    local operating_cost, tax_amount, total_deduction = self:_calculate_day_expenses()
    self.cash_amount = self.cash_amount - total_deduction

    local next_day_state = {
        day_number = self.day_number + 1,
        cash_amount = self.cash_amount
    }

    local summary = {
        day_number = self.day_number,
        operating_cost = operating_cost,
        tax_amount = tax_amount,
        total_deduction = total_deduction,
        cash_after = self.cash_amount,
        next_day = next_day_state.day_number
    }

    GameState.switch(DayEnd, summary, next_day_state)
end

function Game:_update_day_cycle(dt)
    if self.paused then return end

    if self.day_transitioning then
        return
    end

    self.day_time_left = self.day_time_left - dt

    self.order_spawn_timer = self.order_spawn_timer - dt
    if self.order_spawn_timer <= 0 then
        self:_spawn_random_order()
        self.order_spawn_timer = self:_get_order_spawn_interval()
    end

    if self.day_time_left <= 0 then
        self:_end_day()
    end
end

function Game:update(dt)
    Timer.update(dt)
    self:_update_day_cycle(dt)
    mobile_joystick:update(dt)

    Game:_handle_interaction()
    self:_update_interact_prompt(dt)

    if Utils.gamepad_button_pressed('a') or mobile_joystick:consume_interact_pressed() then
        self:_interact()
    end

    Utils.update()
    
    self.world:update(dt)
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end

    self.entities:queue_free_list_update()
    self.designmode:update(dt)
end

function Game:_update_interact_prompt(dt)
    local target_x = self.interact_prompt.x
    local target_y = self.interact_prompt.y
    local target_alpha = 0.0

    if self.nearest_interactable and self.distance_to_nearest < MIN_INTERACTION_DISTANCE then
        local interact_offset = self.nearest_interactable.interact_gui_offset or Vector(0, 0)
        target_x = self.nearest_interactable.position.x + interact_offset.x
        target_y = self.nearest_interactable.position.y + interact_offset.y
        target_alpha = 0.7
    end

    local position_lerp_t = math.min(1, dt * self.interact_prompt.position_lerp_speed)
    local alpha_lerp_t = math.min(1, dt * self.interact_prompt.alpha_lerp_speed)

    self.interact_prompt.x = lerp(self.interact_prompt.x, target_x, position_lerp_t)
    self.interact_prompt.y = lerp(self.interact_prompt.y, target_y, position_lerp_t)
    self.interact_prompt.alpha = lerp(self.interact_prompt.alpha, target_alpha, alpha_lerp_t)
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
        if self.distance_to_nearest > MIN_INTERACTION_DISTANCE then
            self.nearest_interactable = nil
            self.distance_to_nearest = math.huge
        end
    else
        self.distance_to_nearest = math.huge
    end
end

function Game:_interact()
    if self.nearest_interactable then
        if self.distance_to_nearest < MIN_INTERACTION_DISTANCE then
            self.nearest_interactable:on_interact(self.player)
        end
    end
end

function Game:increase_cash(amount)
    self.cash_amount = self.cash_amount + amount
    game_gui:_spawn_cash_delta_popup(amount)
    local cash_sound = love.audio.newSource("assets/sfx/sell_buy_item.wav", "static")
    cash_sound:setVolume(0.7)
    love.audio.play(cash_sound)
end

function Game:decrease_cash(amount)
    self.cash_amount = self.cash_amount - amount
    game_gui:_spawn_cash_delta_popup(-amount)
end

function Game:apply_penalty(amount)
    self:decrease_cash(amount)
    -- play sound
    local penalty_sound = love.audio.newSource("assets/sfx/caught.wav", "static")
    love.audio.play(penalty_sound)
end

function Game:draw()
    Push:start()

    self:_draw_game()

    Push:finish()
end

function Game:_draw_game()
    love.graphics.draw(assets.IMAGES.img_background, 0, 0)
    love.graphics.draw(assets.IMAGES.img_wall, 0, 0)

    self:draw_sorted_entities()
    self.designmode:draw()

    local prompt = self.interact_prompt
    local prompt_x = prompt.x - (prompt.width / 2)
    local prompt_y = prompt.y - (prompt.height / 2)

    love.graphics.setFont(prompt.font)
    love.graphics.setColor(0, 0, 0, 0.8 * prompt.alpha)
    love.graphics.rectangle('fill', prompt_x, prompt_y, prompt.width, prompt.height, prompt.corner_radius, prompt.corner_radius)
    love.graphics.setColor(1, 1, 1, prompt.alpha)
    love.graphics.printf("E", prompt_x, prompt_y + ((prompt.height - prompt.font:getHeight()) / 2), prompt.width, "center")
    love.graphics.setColor(1, 1, 1, 1)

    game_gui:draw()
    mobile_joystick:draw()
    if DEBUGMODE then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Game:draw_sorted_entities()
    -- Sort entities by z_order for proper rendering
    local sorted_entities = {}
    for _, entity in ipairs(self.entities) do
        table.insert(sorted_entities, entity)
    end
    table.sort(sorted_entities, function(a, b)
        return (a.z_order or 0) < (b.z_order or 0)
    end)

    for _, entity in ipairs(sorted_entities) do
        entity:draw()
    end
end

function Game:touchpressed(id, x, y, dx, dy, pressure)
    mobile_joystick:touchpressed(id, x, y, dx, dy, pressure)
end

function Game:touchmoved(id, x, y, dx, dy, pressure)
    mobile_joystick:touchmoved(id, x, y, dx, dy, pressure)
end

function Game:touchreleased(id, x, y)
    mobile_joystick:touchreleased(id, x, y)
end

function Game:resize(w, h)
    -- Push:resize(w, h)
end

function Game:mousepressed(x, y, button)
    game_gui:mousepressed(x, y, button) 
    mobile_joystick:mousepressed(x, y, button)
end

function Game:mousemoved(x, y, dx, dy, istouch)
    mobile_joystick:mousemoved(x, y, dx, dy, istouch)
end

function Game:mousereleased(x, y, button)
    mobile_joystick:mousereleased(x, y, button)
end

function Game:keypressed(key)
    self.designmode:keypressed(key)

    if key == 'e' then
        self:_interact()
    end

    if key == 'p' then
        if BACKGROUND_MUSIC then
            if BACKGROUND_MUSIC:isPlaying() then
                BACKGROUND_MUSIC:pause()
            else
                BACKGROUND_MUSIC:play()
            end
        end
    end
end

return Game