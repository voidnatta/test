local Item = require("src.item")

local RECIPES = {
    [Item.TYPES.COOKED_STEAK] = {
        ingredients = {
            {type = Item.TYPES.STEAK, state = {cooked = true}}
        }
    },
    [Item.TYPES.BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.BREAD},
        }
    },
    [Item.TYPES.DOUBLE_BURGER] = {
        ingredients = {
            {type = Item.TYPES.BREAD},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.STEAK, state = {cooked = true}},
            {type = Item.TYPES.BREAD},
        }
    },
}

local Recipe = {}

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