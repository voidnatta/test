local love = require ("love")

local GameState = require("lib.hump.gamestate")

local gameOver = {}
gameOver.img_background = love.graphics.newImage("assets/export/background.png")

local function get_layout()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local button_w = 260
    local button_h = 64
    local button_x = (sw - button_w) * 0.5
    local button_y = sh * 0.58

    return {
        sw = sw,
        sh = sh,
        button = {
            x = button_x,
            y = button_y,
            width = button_w,
            height = button_h
        }
    }
end

function gameOver:enter()
    self.restartButton = { text = "Restart Game" }
    self.button_click_sound = love.audio.newSource("assets/sfx/pop1.ogg", "static")
    self.game_over_sound = love.audio.newSource("assets/sfx/game_over_bad_chest.wav", "static")
    if StopBackgroundMusic then
        StopBackgroundMusic()
    end
    self.game_over_sound:stop()
    self.game_over_sound:play()
end

function gameOver:update(dt)
    -- Update logic here
end

function gameOver:draw()
    local layout = get_layout()
    love.graphics.clear(0.05, 0.05, 0.08)

    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.draw(self.img_background, 0, -200)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER", 0, layout.sh * 0.22, layout.sw, "center")

    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("Kitchen closed for today.", 0, layout.sh * 0.32, layout.sw, "center")
    
    -- Draw restart button
    local btn = layout.button
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 8, 8)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height, 8, 8)
    love.graphics.printf(self.restartButton.text, btn.x, btn.y + 22, btn.width, "center")
end

function gameOver:mousepressed(x, y, button)
    if button == 1 then
        local btn = get_layout().button
        if x >= btn.x and x <= btn.x + btn.width and 
           y >= btn.y and y <= btn.y + btn.height then
            if self.button_click_sound then
                self.button_click_sound:stop()
                self.button_click_sound:play()
            end
            if PlayBackgroundMusic then
                PlayBackgroundMusic()
            end
            -- Lazy require avoids circular load with scenes.game requiring scenes.game_over.
            local game = require("scenes.game")
            GameState.switch(game, {
                should_reset = true
            })
        end
    end
end

return gameOver