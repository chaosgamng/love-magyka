require "script/node/effect"
require "script/node/node"
require "script/tools"

Item = Node{
    classType = "item",
    name = "item",
    description = {"description"},
    rarity = "common",
    value = 1,
    stackable = true,
    equipment = false,
    stats = nil,
    slot = "",
    consumable = false,
    effect = nil,
    target = "entity",
    verb = "uses",
    preposition = "on",
    
    display = function(self, quantity)
        quantity = quantity or 0
        
        if quantity > 0 then quantity = " x"..tostring(quantity)
        else quantity = "" end
        
        return "{%s}%s{white}%s" % {self.rarity, self.name, quantity}
    end,
    
    update = function(self)
    
    end,
}

function newItem(arg)
    if type(arg) == "string" then
        local item = newItem(require("data/item")[arg])
        
        if item then
            item.name = arg
            return item
        else
            return Item{name=arg}
        end
    elseif type(arg) == "table" then
        local item = deepcopy(arg)
        
        if item.equipment then item.stackable = false end
        
        if item.effect then
            if item.effect[1] == nil then item.effect = {item.effect} end
            
            for k, v in ipairs(item.effect) do
                if v.verb == nil then v.verb = "uses" end
                item.effect[k] = newEffect(v)
            end
        end
        
        if item.stats then
            for k, v in pairs(item.stats) do
                if type(v) ~= "table" then item.stats[k] = {stat = k, value = v, opp = "+"} end
            end
        end
        
        item = Item(item)
        return item
    end
end