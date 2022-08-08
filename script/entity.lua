require "script/node"
require "script/tools"

Entity = Node{
    hp = 0,
    max_hp = 7,
    mp = 0,
    max_mp = 10,
    xp = 0,
    max_xp = 10,
    gp = 0,
    
    name = "name",
    level = 1,
    
    levelUp = function(self)
        self:add("level", 1)
        self:multiply("max_hp", 1.1, "ceil")
        self:multiply("max_mp", 1.1, "ceil")
        self:multiply("max_xp", 1.1, "ceil")
    end,
    
    
    -- CLASS FUNCTION OVERRIDES
    
    
    init = function(self)
        self.hp = self.max_hp
        self.mp = self.max_mp
    end,
    
    set = function(self, key, value)
        if key == "hp" then
            self.hp = value
            
            if self.hp < 0 then self.hp = 0 end
            if self.hp > self.max_hp then self.hp = self.max_hp end
        elseif key == "xp" then
            self.xp = value
            
            while self.xp >= self.max_xp do
                self.xp = self.xp - self.max_xp
                self:levelUp()
            end
        else
            self[key] = value
        end 
    end,
}