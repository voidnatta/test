local Class = require("lib.hump.class")

local Item = Class{
    init = function(self, item_type)
        self.type = item_type
    end
}

-- Item types constants
Item.TYPES = {
    PLATE = "PLATE",
    TOMATO = "TOMATO",
    STEAK = "STEAK",
    BREAD = "BREAD",
    SANDWICH = "SANDWICH",
    BURGER = "BURGER",
    DOUBLE_BURGER = "DOUBLE_BURGER",
    COOKED_STEAK = "COOKED_STEAK"
}

return Item