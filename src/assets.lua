local love = require("love")

ASSETS = {}

ASSETS.IMAGES = {
    -- game scene
    img_background = love.graphics.newImage("assets/export/background.png"),
    img_wall = love.graphics.newImage("assets/export/wall.png"),

    -- counters
    img_tomato_counter = love.graphics.newImage("assets/export/tomato_counter.png"),
    img_empty_counter = love.graphics.newImage("assets/export/empty_counter.png"),
    img_slicer_counter = love.graphics.newImage("assets/export/slicer_counter.png"),
    img_plate_counter = love.graphics.newImage("assets/export/plate_counter.png"),
    img_left_counter = love.graphics.newImage("assets/export/left_counter.png"),
    img_bottom_counter = love.graphics.newImage("assets/export/bottom_counter.png"),
    img_right_counter = love.graphics.newImage("assets/export/right_counter.png"),
    img_steak_counter = love.graphics.newImage("assets/export/steak_counter.png"),
    img_bread_counter = love.graphics.newImage("assets/export/bread_counter.png"),
    img_cheese_counter = love.graphics.newImage("assets/export/cheese_counter.png"),
    img_cook_counter = love.graphics.newImage("assets/export/cook_counter.png"),
    img_order_counter = love.graphics.newImage("assets/export/order_counter.png"),

    -- edible items
    bread_bottom = love.graphics.newImage("assets/export/bread_bottom.png"),
    bread_top = love.graphics.newImage("assets/export/bread_top.png"),
    tomato = love.graphics.newImage("assets/export/tomato.png"),
    tomato_sliced = love.graphics.newImage("assets/export/cutted_tomato.png"),
    cheese = love.graphics.newImage("assets/export/cheese.png"),
    steak = love.graphics.newImage("assets/export/steak.png"),
    steak_cooked = love.graphics.newImage("assets/export/steak_cooked.png")
}

return ASSETS