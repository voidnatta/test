local love = require("love")
local vector = require("lib.hump.vector")

local mobile_joystick = {
    base_position = vector(250, GAME_HEIGHT - 200),
    base_radius = 140,

    knob_position = vector(250, GAME_HEIGHT - 200),
    knob_radius = 60,

    interact_position = vector(GAME_WIDTH - 250, GAME_HEIGHT - 200),
    interact_radius = 70,
    interact_font = love.graphics.newFont(48),

    touch_id = nil,
    interact_touch_id = nil,
    dx = 0,
    dy = 0,
    mouse_pointer_id = "mouse_left",
    interact_pressed = false,
    alpha_target = 0.0
}

local function lerp(current, target, t)
    return current + (target - current) * t
end

function mobile_joystick:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("fill", self.base_position.x, self.base_position.y, self.base_radius)

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.circle("fill", self.knob_position.x, self.knob_position.y, self.knob_radius)

    local interact_alpha = self.alpha_target
    love.graphics.setColor(0, 0, 0, interact_alpha)
    love.graphics.circle("fill", self.interact_position.x, self.interact_position.y, self.interact_radius)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.interact_font)
    love.graphics.printf("E", self.interact_position.x - self.interact_radius, self.interact_position.y - 20, self.interact_radius * 2, "center")
end

function mobile_joystick:update(dt)
    if self.interact_pressed then
        self.alpha_target = lerp(self.alpha_target, 0.9, dt * 20)
    else
        self.alpha_target = lerp(self.alpha_target, 0.75, dt * 20)
    end
end

function mobile_joystick:consume_interact_pressed()
    local pressed = self.interact_pressed
    self.interact_pressed = false
    return pressed
end

function mobile_joystick:get_axis_x()
    return self.dx / self.base_radius
end

function mobile_joystick:get_axis_y()
    return self.dy / self.base_radius
end

function mobile_joystick:clamp_stick(dx, dy, max_radius)
    local len = math.sqrt(dx * dx + dy * dy)
    if len > max_radius then
        dx = dx / len * max_radius
        dy = dy / len * max_radius
    end

    return dx, dy
end

function mobile_joystick:_is_inside_interact_button(screen_x, screen_y)
    local dx = screen_x - self.interact_position.x
    local dy = screen_y - self.interact_position.y
    return (dx * dx + dy * dy) <= (self.interact_radius * self.interact_radius)
end

function mobile_joystick:_start_pointer(id, x, y)
    local screen_x, screen_y = Push:toGame(x, y)
    
    if screen_x == nil or screen_y == nil then
        return
    end

    if self:_is_inside_interact_button(screen_x, screen_y) and self.interact_touch_id == nil then
        self.interact_touch_id = id
        self.interact_pressed = true
        return
    end
    
    local dx = screen_x - self.base_position.x
    local dy = screen_y - self.base_position.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance <= self.base_radius and self.touch_id == nil then
        self.touch_id = id
        self.dx = dx
        self.dy = dy
        self.knob_position = vector(self.base_position.x + dx, self.base_position.y + dy)
    end
end

function mobile_joystick:touchpressed(id, x, y, dx, dy, pressure)
    self:_start_pointer(id, x, y)
end

function mobile_joystick:_move_pointer(id, x, y)
    if self.touch_id ~= id then return end

    local screen_x, screen_y = Push:toGame(x, y)

    if screen_x == nil or screen_y == nil then
        return
    end

    local dx = screen_x - self.base_position.x
    local dy = screen_y - self.base_position.y

    dx, dy = self:clamp_stick(dx, dy, self.base_radius)
    
    self.dx = dx
    self.dy = dy

    self.knob_position = vector(self.base_position.x + dx, self.base_position.y + dy)
end

function mobile_joystick:touchmoved(id, x, y, dx, dy, pressure)
    self:_move_pointer(id, x, y)
end

function mobile_joystick:_end_pointer(id)
    if self.interact_touch_id == id then
        self.interact_touch_id = nil
        return
    end

    if self.touch_id ~= id then return end

    self.touch_id = nil
    self.dx = 0
    self.dy = 0

    self.knob_position = vector(self.base_position.x, self.base_position.y)
end

function mobile_joystick:touchreleased(id, x, y)
    self:_end_pointer(id)
end

function mobile_joystick:mousepressed(x, y, button)
    if button ~= 1 then return end
    self:_start_pointer(self.mouse_pointer_id, x, y)
end

function mobile_joystick:mousemoved(x, y, dx, dy, istouch)
    self:_move_pointer(self.mouse_pointer_id, x, y)
end

function mobile_joystick:mousereleased(x, y, button)
    if button ~= 1 then return end
    self:_end_pointer(self.mouse_pointer_id)
end

return mobile_joystick