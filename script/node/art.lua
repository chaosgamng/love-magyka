require "script/node/effect"
require "script/node/node"

Art = Node{
    classType = "art",
    name = "art",
    description = "description",
    effect = {},
    
    display = function(self)
        return self:get("name")
    end,
}

function newArt(arg)
    if type(arg) == "string" then
        local art = newArt(require("data/art")[arg])
        
        art.name = arg
        return art
    elseif type(arg) == "table" then
        local art = deepcopy(arg)
        
        if art.description then
            if type(art.description) ~= "table" then art.description = {art.description} end
        end
        
        if art.effect then
            if art.effect[1] == nil then art.effect = {art.effect} end
            
            for k, v in ipairs(art.effect) do
                art.effect[k] = newEffect(v)
            end
        end
        
        art = Art(art)
        return art
    end
end