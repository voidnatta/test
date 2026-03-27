local love = require("love")

local GameState = require("lib.hump.gamestate")

local dayEnd = {}

dayEnd.img_background = love.graphics.newImage("assets/export/background.png")

local function get_layout()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local panel_w = math.min(sw - 80, 820)
    local panel_x = (sw - panel_w) * 0.5
    local panel_y = sh * 0.18
    local button_w = 280
    local button_h = 64
    local button_x = (sw - button_w) * 0.5
    local button_y = panel_y + 350

    return {
        sw = sw,
        sh = sh,
        panel_x = panel_x,
        panel_y = panel_y,
        panel_w = panel_w,
        button = {
            x = button_x,
            y = button_y,
            width = button_w,
            height = button_h
        }
    }
end

function dayEnd:enter(_previous, summary, next_day_state)
    self.summary = summary or {
        day_number = 1,
        operating_cost = 0,
        tax_amount = 0,
        total_deduction = 0,
        cash_after = 0,
        next_day = 2
    }

    self.next_day_state = next_day_state or {
        day_number = (self.summary.day_number or 1) + 1,
        cash_amount = self.summary.cash_after or 0
    }

    self.continue_button = {
        width = 240,
        height = 64,
        text = "Start Next Day"
    }

    if self.summary.cash_after and self.summary.cash_after < 0 then
        self.continue_button.text = "Bankrupt - Game Over"
    end

    self.button_click_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
    self.good_day_sound = love.audio.newSource("assets/sfx/Item2A.wav", "static")

    if self.summary.cash_after and self.summary.cash_after >= 0 then
        self.good_day_sound:stop()
        self.good_day_sound:play()
    end
end

function dayEnd:update(_dt)
end

function dayEnd:draw()
    local layout = get_layout()
    love.graphics.clear(0.05, 0.05, 0.08)

    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.draw(self.img_background, 0, -200)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("DAY " .. tostring(self.summary.day_number) .. " COMPLETE", layout.panel_x, layout.panel_y, layout.panel_w, "center")

    local y = layout.panel_y + 80
    local line_h = 44

    love.graphics.printf(string.format("Operating Costs: -$%.2f", self.summary.operating_cost or 0), layout.panel_x, y, layout.panel_w, "center")
    love.graphics.printf(string.format("Taxes: -$%.2f", self.summary.tax_amount or 0), layout.panel_x, y + line_h, layout.panel_w, "center")
    love.graphics.printf(string.format("Total Deduction: -$%.2f", self.summary.total_deduction or 0), layout.panel_x, y + line_h * 2, layout.panel_w, "center")

    love.graphics.setColor(0.6, 1, 0.6, 1)
    love.graphics.printf(string.format("Cash Remaining: $%.2f", self.summary.cash_after or 0), layout.panel_x, y + line_h * 3 + 10, layout.panel_w, "center")

    if self.summary.cash_after and self.summary.cash_after < 0 then
        love.graphics.setColor(1, 0.35, 0.35, 1)
        love.graphics.printf("Selling burgers is not easy! Try again :).", layout.panel_x, y + line_h * 4 + 26, layout.panel_w, "center")
    else
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf("Day " .. tostring(self.summary.next_day or "?") .. " will be a little bit harder.", layout.panel_x, y + line_h * 4 + 26, layout.panel_w, "center")
    end

    local btn = layout.button
    love.graphics.setColor(0.22, 0.22, 0.26, 1)
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 8, 8)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 8, 8)
    love.graphics.printf(self.continue_button.text, btn.x, btn.y + 22, btn.width, "center")
end

function dayEnd:_continue()
    if self.button_click_sound then
        self.button_click_sound:stop()
        self.button_click_sound:play()
    end

    if self.summary.cash_after and self.summary.cash_after < 0 then
        local game_over = require("scenes.game_over")
        GameState.switch(game_over)
        return
    end

    local game = require("scenes.game")
    GameState.switch(game, {should_reset = false, next_day_state = self.next_day_state})
end

function dayEnd:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    local btn = get_layout().button
    if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
        self:_continue()
    end
end

function dayEnd:keypressed(key)
    if key == "return" or key == "space" then
        self:_continue()
    end
end

return dayEnd
