local Item = require("src.item")
local Recipe = {}

Recipe.RECIPES_TYPES = {
    COOKED_STEAK = "COOKED_STEAK",

    BURGER = "BURGER",
    DOUBLE_BURGER = "DOUBLE_BURGER",

    SLICED_TOMATO = "SLICED_TOMATO",
    CHEESE_SLICE = "CHEESE_SLICE",

    CHEESEBURGER = "CHEESEBURGER",
    TOMATO_BURGER = "TOMATO_BURGER",
    FULL_BURGER = "FULL_BURGER",
    DOUBLE_CHEESEBURGER = "DOUBLE_CHEESEBURGER",

    STEAK_WITH_TOMATO = "STEAK_WITH_TOMATO",
    CHEESE_STEAK = "CHEESE_STEAK",
    TOMATO_CHEESE = "TOMATO_CHEESE",
}

local RECIPES = {
    [Recipe.RECIPES_TYPES.COOKED_STEAK] = {
        ingredients = {
            {type = Item.TYPES.STEAK, state = {cooked = true}}
        }
    },

    [Recipe.RECIPES_TYPES.BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.DOUBLE_BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.SLICED_TOMATO] = {
        ingredients = {
            {type = Item.TYPES.TOMATO, state = {sliced = true}}
        }
    },

    [Recipe.RECIPES_TYPES.CHEESE_SLICE] = {
        ingredients = {
            {type = Item.TYPES.CHEESE, state = {sliced = true}}
        }
    },

    [Recipe.RECIPES_TYPES.CHEESEBURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.CHEESE},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.TOMATO_BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.TOMATO, state = {sliced = true}},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.FULL_BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.CHEESE},
            {type = Item.TYPES.TOMATO, state = {sliced = true}},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.DOUBLE_CHEESEBURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.CHEESE},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.CHEESE},
            {type = Item.TYPES.BREAD},
        }
    },

    [Recipe.RECIPES_TYPES.STEAK_WITH_TOMATO] = {
        ingredients = {
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.TOMATO, state = {sliced = true}},
        }
    },

    [Recipe.RECIPES_TYPES.CHEESE_STEAK] = {
        ingredients = {
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.CHEESE},
        }
    },

    [Recipe.RECIPES_TYPES.TOMATO_CHEESE] = {
        ingredients = {
            {type = Item.TYPES.TOMATO, state = {sliced = true}},
            {type = Item.TYPES.CHEESE},
        }
    },
}

function Recipe:get_recipes()
    return RECIPES
end

function Recipe:match_ingredient(item, ingredient)
    if item.type ~= ingredient.type then
        return false
    end

    if ingredient.state then
        for key, value in pairs(ingredient.state) do
            if item.state[key] ~= value then
                return false
            end
        end
    end

    return true
end

function Recipe:matches_recipe(contents, recipe)
    if #contents ~= #recipe.ingredients then
        return false
    end

    local used = {}

    for _, ingredient in ipairs(recipe.ingredients) do
        local found = false

        for i, item in ipairs(contents) do
            if not used[i] and self:match_ingredient(item, ingredient) then
                used[i] = true
                found = true
                break
            end
        end

        if not found then
            return false
        end
    end

    return true
end

function Recipe:try_craft(contents)
    for recipe_type, recipe in pairs(RECIPES) do
        if self:matches_recipe(contents, recipe) then
            -- print("Crafted: " .. tostring(recipe_type))

            return recipe_type
        end
    end

    return nil
end

return Recipe