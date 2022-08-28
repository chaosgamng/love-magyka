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