require "script/node/effect"
require "script/node/node"

Art = Node{
    classType = "art",
    name = "art",
    effect = {},
    hpCost = nil,
    mpCost = nil,
    amount = 1,
    targetSelf = true,
    targetOther = true,
    verb = "casts",
    preposition = "on",
    
    cast = function(self, source, target)
        target = target or source
        local text = {}
        local line = ""
        
        local preposition = ""
        local verb = " "..self:get("verb")
        if self:get("preposition") ~= "" then preposition = " "..self:get("preposition")
        else verb = "" end
        
        if source == target then
            line = "%s%s %s, " % {source:get("name"), verb, self:display()}
        else
            line = "%s%s %s%s " % {source:get("name"), verb, self:get("name"), preposition}
        end
        
        if self:get("target") == "entity" then
            if source ~= target then line = line..target:get("name")..", " end
            
            for i = 1, self:get("amount") do
                table.insert(text, target:defend(source, self:get("effect"), line))
            end
        end
        
        return text
    end,
}

function newArt(arg)
    if type(arg) == "string" then
        local art = newArt(require("data/art")[arg])
        
        art.name = arg
        return art
    elseif type(arg) == "table" then
        local art = deepcopy(arg)
        
        if art.effect then
            if art.effect[1] == nil then art.effect = {art.effect} end
            
            for k, v in ipairs(art.effect) do
                art.effect[k] = newEffect(v)
            end
        end
        
        if type(art.hp) == "number" then art.hp = {art.hp} end
        if type(art.mp) == "number" then art.mp = {art.mp} end
        
        art = Art(art)
        art:update()
        
        return art
    end
end