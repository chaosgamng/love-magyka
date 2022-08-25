require "script/node/node"
require "script/tools"

Effect = Node{
    classType = "effect",
    name = "effect",
    hp = nil,
    mp = nil,
    hpCost = nil,
    mpCost = nil,
    crit = nil,
    critBonus = 0,
    amount = 1,
    target = "entity",
    targetSelf = true,
    targetOther = true,
    color = "white",
    verb = "casts",
    preposition = "on",
    
    -- Passives
    
    turns = 1,
    stats = nil,
    buff = true,
    passiveType = "",
    
    use = function(self, parent, source, target)
        target = target or source
        local text = {}
        local line = "%s %s %s" % {source:get("name"), self:get("verb"), parent:display()}
        
        if source ~= target then line = "%s %s" % {line, self:get("preposition")} end
        
        if self:get("target") == "entity" then
            if source ~= target then line = "%s %s, " % {line, target:get("name")}
            else line = line..", " end
            
            if hpCost and parent.hp then parent:add("hp", -hpCost) end
            if mpCost and parent.mp then parent:add("mp", -mpCost) end
            
            for i = 1, self:get("amount") do
                appendTable(text, target:defend(source, {self}, line))
            end
        end
        
        return text
    end,
}

function newEffect(arg)
    if type(arg) == "string" then
        local effect = newEffect(require("data/effect")[arg])
        
        if effect then return effect else return effect{} end
    elseif type(arg) == "table" then
        local effect = deepcopy(arg)
        
        if effect.passive then
            if effect.passive[1] == nil then effect.passive = {effect.passive} end
            
            for k, v in ipairs(effect.passive) do
                effect.passive[k] = newEffect(v)
            end
        end
        
        return Effect(effect)
    end
end