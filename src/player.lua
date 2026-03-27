local love = require("love")

local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local Utils = require("src.utils")
local Timer = require("lib.hump.timer")
local mobile_joystick = require("src.gui.mobile_joystick")

local DynamicEntity = require("src.dynamic_entity")

local BLINK_INTERVAL_SECONDS = 4
local BLINK_DURATION_SECONDS = 0.2
local PLAYER_FRAMES = {
    love.graphics.newImage("assets/export/player_1.png"),
    love.graphics.newImage("assets/export/player_2.png")
}

local Player = Class{
    __includes = DynamicEntity,
    init = function(self, position, speed)
        DynamicEntity.init(self, position, "dynamic")

        self.speed = speed or 300
        self.area_radius = 40
        self.objects_in_range = {}
        self.item_object_holding = nil
        self.name = "Player"
        self.color = {1, 1, 1, 1}
        self.sprite_frame_index = 1
        self.sprite = PLAYER_FRAMES[self.sprite_frame_index]
        self.custom_shape_size = Vector(48, 24)
        self.placement_offset = Vector(-100, 90)
        self.z_order = 1
    end
}

function Player:load(_game)
    DynamicEntity.load(self, _game)

    Timer.every(BLINK_INTERVAL_SECONDS, function()
        self.sprite_frame_index = 2
        self.sprite = PLAYER_FRAMES[self.sprite_frame_index]

        Timer.after(BLINK_DURATION_SECONDS, function()
            self.sprite_frame_index = 1
            self.sprite = PLAYER_FRAMES[self.sprite_frame_index]
        end)
    end)
end

function Player:has_item_object()
    return self.item_object_holding ~= nil
end

function Player:get_item_object()
    return self.item_object_holding
end

function Player:set_item_object(item_object)
    self.item_object_holding = item_object
end

function Player:update(dt)
    if self.game.paused then return end

    local horizontal = Utils.get_axis('a', 'd', 'leftx')
    local vertical = Utils.get_axis('w', 's', 'lefty')

    horizontal = horizontal + mobile_joystick:get_axis_x()
    vertical = vertical + mobile_joystick:get_axis_y()

    if horizontal > 1 then horizontal = 1 end
    if horizontal < -1 then horizontal = -1 end
    if vertical > 1 then vertical = 1 end
    if vertical < -1 then vertical = -1 end
    
    -- normalize player movement
    local len = math.sqrt(horizontal * horizontal + vertical * vertical)
    if len > 1 then
        horizontal = horizontal / len
        vertical = vertical / len
    end

    if horizontal > 0 then
        self.size.x = math.abs(self.size.x) * -1
    elseif horizontal < 0 then
        self.size.x = math.abs(self.size.x) * 1
    end  

    self.body:setLinearVelocity(horizontal * self.speed, vertical * self.speed)

    local position_x, position_y = self.body:getPosition()
    self.position.x = position_x
    self.position.y = position_y
end

function Player:draw()
    DynamicEntity.draw(self)

    -- love.graphics.setColor(0, 1, 1, 0.2)
    -- love.graphics.circle('fill', position_x, position_y, self.area_radius)
end

return Player