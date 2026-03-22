local love = require("love")

local utils = {}
local gamepad = nil
local gamepad_buttons_pressed = {}

local function refresh_gamepad()
    local joysticks = love.joystick.getJoysticks()
    gamepad = nil

    for _, joystick in ipairs(joysticks) do
        if joystick:isGamepad() then
            gamepad = joystick
            break
        end
    end
end

function utils.get_axis(negative_key, positive_key, axis_name)
    local value = 0
    
    if love.keyboard.isDown(negative_key) then value = value - 1 end
    if love.keyboard.isDown(positive_key) then value = value + 1 end
    
    if gamepad then
        local axis = gamepad:getGamepadAxis(axis_name)
        
        if math.abs(axis) > 0.15 then
            value = value + axis
        end
    end
    
    if value > 1 then value = 1 end
    if value < -1 then value = -1 end
    
    return value
end

function love.gamepadpressed(joystick, button)
    gamepad = joystick
    gamepad_buttons_pressed[button] = true
end

function utils.update()
    gamepad_buttons_pressed = {}

    if not gamepad or not gamepad:isConnected() then
        refresh_gamepad()
    end
end

function love.joystickadded(joystick)
    if not gamepad and joystick:isGamepad() then
        gamepad = joystick
    end
end

function love.joystickremoved(joystick)
    if gamepad == joystick then
        refresh_gamepad()
    end
end

function utils.gamepad_button_pressed(button)
    return gamepad_buttons_pressed[button] or false
end

function utils.check_radius_collision(ax, ay, bx, by, ar, br)
    return (bx - ax)^2 + (by - ay)^2 < (ar + br)^2
end

refresh_gamepad()
return utils