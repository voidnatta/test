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
    CHEESE = "CHEESE"
}

return Item