require "script/node/item"
require "script/node/node"

Recipe = Node{
    name = "item",
    ingredients = nil,
    quantity = 1,
    station = "none",
}

recipes = {}
for result, recipe in pairs(require("data/recipe")) do
    for name, quantity in pairs(recipe.ingredients) do
        if recipes[name] == nil then recipes[name] = {} end
        
        table.insert(recipes[name], result)
    end
end

function newRecipe(arg)
    if type(arg) == "string" then
        local recipe = require("data/recipe")[arg]
        recipe.name = arg
        return newRecipe(recipe)
    elseif type(arg) == "table" then
        local recipe = deepcopy(arg)
        
        if recipe.item == nil then recipe.item = newItem(recipe.name) end
        
        recipe = Recipe(recipe)
        return recipe
    end
end