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