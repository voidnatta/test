local Item = require("src.item")
local Recipe = {}

local assets = require("src.assets")

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
            {type = Item.TYPES.CHEESE}
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

function Recipe:get_recipe(name)
    return RECIPES[name] or nil
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
            print("Crafted: " .. tostring(recipe_type))

            return recipe_type
        end
    end

    return nil
end

function Recipe:get_order_layer_image(layer)
    if layer.kind == "bread_bottom" then
        return assets.IMAGES.bread_bottom
    end

    if layer.kind == "bread_top" then
        return assets.IMAGES.bread_top
    end

    if layer.type == "TOMATO" then
        if layer.state and layer.state.sliced then
            return assets.IMAGES.tomato_sliced
        end
        return assets.IMAGES.tomato
    end

    if layer.type == "CHEESE" then
        return assets.IMAGES.cheese
    end

    if layer.type == "STEAK" then
        if layer.state and layer.state.cooked then
            return assets.IMAGES.steak_cooked
        end
        return assets.IMAGES.steak
    end

    return nil
end

function Recipe:build_recipe_layers(recipe)
    if not recipe or not recipe.ingredients then
        return {}
    end

    local layers = {}
    local bread_count = 0

    for _, ingredient in ipairs(recipe.ingredients) do
        if ingredient.type == "BREAD" then
            bread_count = bread_count + 1
        end
    end

    if bread_count > 0 then
        table.insert(layers, {kind = "bread_bottom"})
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        if ingredient.type ~= "BREAD" then
            table.insert(layers, ingredient)
        end
    end

    if bread_count > 1 then
        table.insert(layers, {kind = "bread_top"})
    end

    return layers
end

function Recipe:prettify_recipe_name(recipe_type)
    return recipe_type:gsub("_", " ")
end

return Recipe