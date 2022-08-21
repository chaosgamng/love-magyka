require "script/node/node"

Effect = Node{
    classType = "effect",
    hp = {0, 0},
    mp = {0, 0},
    crit = 0,
    passive = nil,
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