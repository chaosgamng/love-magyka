require "script/node/node"

Effect = Node{
    classType = "art",
    name = "art",
    hp = nil,
    mp = nil,
    hpCost = nil,
    mpCost = nil,
    crit = nil,
    critBonus = 0,
    amount = 1,
    targetSelf = true,
    targetOther = true,
    verb = "casts",
    preposition = "on",
    
    use = function(self, source, target)
        target = target or source
        local text = {}
        local line = "%s %s" % {source:get("name"), self:get("verb")}
        
        if source ~= target then line = "%s %s" % {line, self:get("preposition")} end
        
        if self:get("target") == "entity" then
            if source ~= target then line = "%s %s," % {line, target:get("name")} end
            
            for i = 1, self:get("amount") do
                table.insert(text, target:defend(source, self:get("effect"), line))
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