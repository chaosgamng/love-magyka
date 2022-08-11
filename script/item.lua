require "script/effect"
require "script/node"
require "script/tools"

Item = Node{
    name = "item",
    rarity = "common",
    stackable = true,
    equipment = false,
    slot = "",
    consumable = false,
    effect = nil,
    stats = {},
    
    display = function(self, quantity)
        quantity = quantity or 0
        
        if quantity > 0 then quantity = " x"..tostring(quantity)
        else quantity = "" end
        
        return "{%s}%s{white}%s" % {self.rarity, self.name, quantity}
    end,
    
    update = function(self)
        if self.equipment then self.stackable = false end
    end,
}