local love = require("love")

local Recipe = require("src.recipe")

local game_gui = {
    game = nil,
    cash_delta_popups = {},
    play_button = {
        x = GAME_WIDTH * 0.5,
        y = GAME_HEIGHT * 0.5,
        width = 250,
        height = 80
    },
    background_alpha = 0.8,
    button_click_sound = love.audio.newSource("assets/sfx/Menu2A.wav", "static"),
    day_gui = {
        x = GAME_WIDTH - 280,
        y = -200.0,
        w = 260,
        h = 80
    },
    order_gui_offset = {
        x = 0,
        y = -200.0
    }
}

local CASH_GUI_X = 15
local CASH_GUI_Y_OFFSET = 95
local CASH_GUI_WIDTH = 300
local CASH_GUI_HEIGHT = 70
local CASH_DELTA_FLOAT_DISTANCE = 42
local CASH_DELTA_FLOAT_DURATION = 1.0

local ORDER_CARD_WIDTH = 250
local ORDER_CARD_HEIGHT = 86
local ORDER_CARD_MARGIN = 12
local ORDER_CARD_X = 25
local ORDER_CARD_Y = 18
local ORDER_ICON_SIZE = 48

function game_gui:load(game)
    self.game = game
    self.cash_currency_font = love.graphics.newFont(42)
    self.cash_value_font = love.graphics.newFont(48)
    self.cash_label_font = love.graphics.newFont(16)
    self.cash_status_font = love.graphics.newFont(14)
    self.cash_delta_font = love.graphics.newFont(28)
    self.order_card_font = love.graphics.newFont(18)
    self.play_font = love.graphics.newFont(42)

    self.button_click_sound:setVolume(0.2)
end

function game_gui:draw()
    self:_draw_cash_gui()
    self:_draw_day_gui()
    self:_draw_order_cards()
    self:_draw_play_screen()
    if DEBUGMODE then self:_draw_debug_info() end
end

function game_gui:_draw_debug_info()
        
    local mouse_pos_x, mouse_pos_y = Push:toGame(love.mouse.getX(), love.mouse.getY())
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', mouse_pos_x + 25, mouse_pos_y, 320, 40)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("%.2f", mouse_pos_x) .. ", " .. string.format("%.2f", mouse_pos_y), mouse_pos_x + 25, mouse_pos_y)

    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print('Memory actually used (in Mb): ' .. string.format("%.2f", collectgarbage('count') / 1000.0) , 10, 560)
end

function game_gui:_draw_day_gui()
    local remaining = math.max(0, self.game.day_time_left)
    local minutes = math.floor(remaining / 60)
    local seconds = math.floor(remaining % 60)

    love.graphics.setColor(0.07, 0.07, 0.07, 0.85)
    love.graphics.rectangle("fill", self.day_gui.x, self.day_gui.y, self.day_gui.w, self.day_gui.h, 10, 10)

    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.day_gui.x, self.day_gui.y, self.day_gui.w, self.day_gui.h, 10, 10)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.cash_label_font)
    love.graphics.print("DAY " .. tostring(self.game.day_number), self.day_gui.x + 16, self.day_gui.y + 14)

    love.graphics.setFont(self.cash_currency_font)
    love.graphics.print(string.format("%02d:%02d", minutes, seconds), self.day_gui.x + 16, self.day_gui.y + 32)
end

function game_gui:_draw_order_cards()
    if not self.game.order_counter or not self.game.order_counter.orders then
        return
    end

    local recipes = Recipe:get_recipes()

    for i, order in ipairs(self.game.order_counter.orders) do
        local card_x = ORDER_CARD_X + (i - 1) * (ORDER_CARD_WIDTH + ORDER_CARD_MARGIN) + self.order_gui_offset.x
        local card_y = ORDER_CARD_Y + self.order_gui_offset.y

        love.graphics.setColor(0.08, 0.08, 0.08, 0.85)
        love.graphics.rectangle("fill", card_x, card_y, ORDER_CARD_WIDTH, ORDER_CARD_HEIGHT, 10, 10)

        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", card_x, card_y, ORDER_CARD_WIDTH, ORDER_CARD_HEIGHT, 10, 10)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(self.order_card_font)
        love.graphics.print(Recipe:prettify_recipe_name(order.recipe_name), card_x + 8, card_y + 6)

        local layers = Recipe:build_recipe_layers(order.recipe_type)
        local content_start_x = card_x + 8
        local content_y = card_y + 36
        local icon_gap = 4
        local available_width = ORDER_CARD_WIDTH - 16
        local max_icons = math.max(1, math.floor((available_width + icon_gap) / (ORDER_ICON_SIZE + icon_gap)))


        for layer_index, layer in ipairs(layers) do
            if layer_index > max_icons then
                break
            end

            local image = Recipe:get_order_layer_image(layer)
            if image then
                local slot_x = content_start_x + (layer_index - 1) * (ORDER_ICON_SIZE + icon_gap)
                local slot_y = content_y
                local image_w = image:getWidth()
                local image_h = image:getHeight()
                local scale = math.min(ORDER_ICON_SIZE / image_w, ORDER_ICON_SIZE / image_h)
                local draw_w = image_w * scale
                local draw_h = image_h * scale
                local draw_x = slot_x + (ORDER_ICON_SIZE - draw_w) * 0.5
                local draw_y = slot_y + (ORDER_ICON_SIZE - draw_h) * 0.5

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(
                    image,
                    draw_x,
                    draw_y,
                    0,
                    scale,
                    scale
                )

                
            end
        end
        if self.game.can_get_new_order then
            local bar_width = (order.expire_time / self.game.recipe_expire_time) * (ORDER_CARD_WIDTH - 18)
            
            local bar_color = {0.38, 0.92, 0.28, 0.8}
            if order.expire_time < 8.0 then
                bar_color = {0.94, 0.85, 0.28, 0.8}
            elseif order.expire_time < 3.0 then
                bar_color = {1, 0.2, 0.2, 0.8}
            end
            
            love.graphics.setColor(bar_color)
            love.graphics.rectangle("fill", card_x + 10, card_y + ORDER_CARD_HEIGHT - 10, bar_width, 4)
        end
    end
end

function game_gui:_draw_cash_gui()
    local cash_x = CASH_GUI_X
    local cash_y = GAME_HEIGHT - CASH_GUI_Y_OFFSET
    local cash_width = CASH_GUI_WIDTH
    local cash_height = CASH_GUI_HEIGHT
    local corner_radius = 12

    -- Determine color based on cash level
    local cash_color = {0.2, 0.8, 0.2}  -- Green (healthy)
    local text_color = {0, 0, 0}         -- Black text

    if self.game.cash_amount < 20 then
        cash_color = {0.9, 0.2, 0.2}  -- Red (critical)
        text_color = {1, 1, 1}         -- White text for better contrast
    elseif self.game.cash_amount < 50 then
        cash_color = {0.9, 0.6, 0.1}  -- Orange (warning)
        text_color = {0, 0, 0}         -- Black text
    end

    -- Background panel with border
    love.graphics.setColor(cash_color[1], cash_color[2], cash_color[3], 0.15)
    love.graphics.rectangle('fill', cash_x, cash_y, cash_width, cash_height, corner_radius, corner_radius)

    love.graphics.setColor(cash_color[1], cash_color[2], cash_color[3], 0.6)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', cash_x, cash_y, cash_width, cash_height, corner_radius, corner_radius)

    -- Cash amount
    love.graphics.setColor(cash_color[1], cash_color[2], cash_color[3], 1)
    love.graphics.setFont(self.cash_currency_font)
    love.graphics.print("$", cash_x + 20, cash_y + 12)

    love.graphics.setColor(text_color[1], text_color[2], text_color[3], 1)
    love.graphics.setFont(self.cash_value_font)
    local cash_text = string.format("%.2f", self.game.cash_amount)
    love.graphics.print(cash_text, cash_x + 60, cash_y + 8)

    love.graphics.setColor(text_color[1], text_color[2], text_color[3], 0.6)
    love.graphics.setFont(self.cash_status_font)

    self:_draw_cash_delta_popups()
end

function game_gui:_spawn_cash_delta_popup(amount)
    local cash_y = GAME_HEIGHT - CASH_GUI_Y_OFFSET
    local start_x = CASH_GUI_X + CASH_GUI_WIDTH - 24
    local stack_offset = math.min(#self.cash_delta_popups, 3) * 16
    local start_y = cash_y + 30 - stack_offset
    local popup = {
        text = string.format("%+.2f", amount),
        x = start_x,
        y = start_y,
        alpha = 1.0,
        r = amount >= 0 and 0.2 or 1.0,
        g = amount >= 0 and 0.95 or 0.3,
        b = amount >= 0 and 0.25 or 0.3
    }

    table.insert(self.cash_delta_popups, popup)

    Timer.tween(
        CASH_DELTA_FLOAT_DURATION,
        popup,
        {
            y = popup.y - CASH_DELTA_FLOAT_DISTANCE,
            alpha = 0.0
        },
        "out-quad",
        function()
            for i = #self.cash_delta_popups, 1, -1 do
                if self.cash_delta_popups[i] == popup then
                    table.remove(self.cash_delta_popups, i)
                    break
                end
            end
        end
    )
end

function game_gui:_draw_cash_delta_popups()
    if not self.cash_delta_popups then
        return
    end

    love.graphics.setFont(self.cash_delta_font)
    for _, popup in ipairs(self.cash_delta_popups) do
        love.graphics.setColor(0, 0, 0, popup.alpha * 0.45)
        love.graphics.print(popup.text, popup.x + 2, popup.y + 2)

        love.graphics.setColor(popup.r, popup.g, popup.b, popup.alpha)
        love.graphics.print(popup.text, popup.x, popup.y)
    end
end

function game_gui:mousepressed(x, y, button)
    x, y = Push:toGame(x, y)
    local offset_x, offset_y = self.play_button.width * 0.5, self.play_button.height * 0.5
    local center_x = self.play_button.x - offset_x
    local center_y = self.play_button.y - offset_y
    
    if x >= center_x and x <= center_x + self.play_button.width
    and y >= center_y and y <= center_y + self.play_button.height then
        if not self.game.paused then
            return
        end
        self.game:start_the_game()
        self.button_click_sound:play()
    end
end

function game_gui:_draw_play_screen()
    if not self.game.show_play_screen then
        return
    end

    love.graphics.setColor(0, 0, 0, self.background_alpha or 0.8)
    love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    local offset_x, offset_y = self.play_button.width * 0.5, self.play_button.height * 0.5
    local center_x = self.play_button.x - offset_x
    local center_y = self.play_button.y - offset_y

    love.graphics.setColor(0.22, 0.22, 0.26, 1)
    love.graphics.rectangle("fill", center_x, center_y, self.play_button.width, self.play_button.height, 8, 8)

    love.graphics.setFont(self.play_font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", center_x, center_y, self.play_button.width, self.play_button.height, 8, 8)
    love.graphics.printf("PLAY", center_x, center_y + 15, self.play_button.width, "center")
end

return game_gui