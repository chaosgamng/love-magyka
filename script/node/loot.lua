require "script/node/item"
require "script/node/node"

Loot = Node{
    xp = nil,
    gp = nil,
    drops = {},
    mode = "normal",
    
    drop = function(self)
        local items = {}
        
        for k, v in ipairs(self.drops) do
            if rand(1, 100) <= v[3] then
                local quantity = 0
                if type(v[2]) == "table" then quantity = rand(v[2])
                else quantity = v[2] end
                
                table.insert(items, {newItem(v[1]), quantity})
            end
        end
        
        return items
    end,
}

function newLoot(arg)
    if type(arg) == "string" then
        local loot = require("data/loot")[arg]
        loot.name = arg
        return newLoot(loot)
    elseif type(arg) == "table" then
        local loot = deepcopy(arg)
        
        loot = Loot(loot)
        return loot
    end
end