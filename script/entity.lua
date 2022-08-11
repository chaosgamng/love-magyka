require "script/effect"
require "script/globals"
require "script/node"
require "script/tools"

Entity = Node{
    hp = 0,
    mp = 0,
    xp = 0,
    maxXp = 10,
    gp = 0,
    
    name = "name",
    level = 1,
    attackText = "attacks",
    
    stats = {},
    baseStats = {},
    
    equipment = {
        weapon = "",
        shield = "",
        helmet = "",
        body = "",
        hands = "",
        legs = "",
        feet = "",
        ring = "",
        acc = "",
    },
    inventory = {},
    
    levelUp = function(self)
        self:add("level", 1)
        self:multiply("max_hp", 1.1, "ceil")
        self:multiply("max_mp", 1.1, "ceil")
        self:multiply("max_xp", 1.1, "ceil")
    end,
    
    
    -- INVENTORY / EQUIPMENT
    
    
    numOfItem = function(self, item)
        local quantity = 0
        local name = ""
        
        if type(item) == "string" then name = item
        else name = item:get("name") end
        
        for k, v in ipairs(self.inventory) do
            if v[1]:get("name") == name then
                if v[1]:get("stackable") then quantity = v[2]
                else quantity = quantity + 1 end
            end
        end
        
        return quantity
    end,
    
    addItem = function(self, item, quantity)
        local quantity = quantity or 1
        item:update()
        
        if self:numOfItem(item) > 0 and item:get("stackable") then
            for k, v in ipairs(self.inventory) do
                if v[1] == item then
                    v[2] = v[2] + quantity
                    break
                end
            end
        elseif item:get("stackable") then
            table.insert(self.inventory, {item, quantity})
        else
            for i = 1, quantity do table.insert(self.inventory, {item, 1}) end
        end
    end,
    
    removeItem = function(self, item, quantity)
        local quantity = quantity or 1
        
        if quantity > self:numOfItem(item) then quantity = self:numOfItem(item) end
        
        if self:numOfItem(item) > 0 then
            for k, v in ipairs(self.inventory) do
                if v[1] == item then
                    if v[1]:get("stackable") then
                        if quantity == v[2] then table.remove(self.inventory, k)
                        else v[2] = v[2] - quantity end
                    else
                        table.remove(self.inventory, k)
                    end
                    break
                end
            end
        end
    end,
    
    equip = function(self, item)
        local slot = item:get("slot")
        item:update()
        
        self:unequip(slot)
        self.equipment[slot] = item
        self:removeItem(item)
    end,
    
    unequip = function(self, slot)
        if self.equipment[slot] ~= "" then
            self.equipment[slot]:update()
            self:addItem(self.equipment[slot])
            self.equipment[slot] = ""
        end
    end,
    
    
    -- BATTLING / STATS
    
    
    attack = function(self)
        local weapon = self.equipment["weapon"]
        
        if weapon ~= "" then
            return weapon.effect
        else
            return Effect{hp={-1, -1}}
        end
    end,
    
    defend = function(self, source, effect)
        local hp = 0
        local mp = 0
        local passive = false
        local text = ""
        
        if self == source then text = "%s %s, " % {self:get("name"), self:get("attackText")}
        else text = "%s %s %s, " % {source:get("name"), self:get("attackText"), self:get("name")} end
        
        if effect:get("hp") then
            hp = rand(effect:get("hp"))
        elseif effect:get("mp") then
            mp = rand(effect:get("mp"))
        end
        
        if hp < 0 and mp < 0 then text = text.."dealing %d and %d damage." % {math.abs(hp), math.abs(mp)}
        elseif hp < 0 then text = text.."dealing %d damage." % {math.abs(hp)}
        elseif mp < 0 then text = text.."dealing %d damage." % {math.abs(mp)} end
        
        self:add("hp", hp)
        self:add("mp", mp)
        
        return text
    end,
    
    
    -- CLASS FUNCTION OVERRIDES
    
    
    init = function(self)
        for k, v in ipairs(stats) do
            self.stats[v] = 0
            self.baseStats[v] = 0
        end
        
        for k, v in ipairs(extraStats) do
            self.stats[v] = 0
            self.baseStats[v] = 0
        end
        
        self.stats["maxHp"] = 7
        self.baseStats["maxHp"] = 7
        self.hp = 7
        self.stats["maxMp"] = 7
        self.baseStats["maxMp"] = 7
        self.mp = 7
    end,
    
    set = function(self, key, value)
        if key == "hp" then
            self.hp = value
            
            if self.hp < 0 then self.hp = 0 end
            if self.hp > self.stats.maxHp then self.hp = self.stats.maxHp end
        elseif key == "mp" then
            self.mp = value
            
            if self.mp < 0 then self.mp = 0 end
            if self.mp > self.stats.maxMp then self.mp = self.stats.maxMp end
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