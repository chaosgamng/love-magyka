require "script/node/effect"
require "script/node/node"
require "script/tools"

Item = Node{
    classType = "item",
    name = "item",
    description = "description",
    rarity = "common",
    value = 1,
    stackable = true,
    equipment = false,
    stats = {},
    slot = "",
    consumable = false,
    effect = nil,
    target = "entity",
    verb = "",
    
    display = function(self, quantity)
        quantity = quantity or 0
        
        if quantity > 0 then quantity = " x"..tostring(quantity)
        else quantity = "" end
        
        return "{%s}%s{white}%s" % {self.rarity, self.name, quantity}
    end,
    
    update = function(self)
        if self.equipment then self.stackable = false end
    end,
    
    use = function(self, source, target)
        target = target or source
        local text = ""
        
        if source == target then text = "%s uses %s, " % {source:get("name"), self:display()}
        else text = "%s uses %s on " % {source:get("name"), self:display(), target:get("name")} end
        
        if self:get("target") == "entity" then
            if source ~= target then text = text..target:get("name")..", " end
            return target:defend(source, self:get("effect"), text)
        end
    end,
}

function newItem(arg)
    if type(arg) == "string" then
        local item = newItem(require("data/item")[arg])
        
        if item then return item else return Item{name=arg} end
    elseif type(arg) == "table" then
        local item = deepcopy(arg)
        
        if item.effect then
            if item.effect[1] == nil then item.effect = {item.effect} end
            
            for k, v in ipairs(item.effect) do
                item.effect[k] = newEffect(v)
            end
        end
        
        return Item(item)
    end
end