require "script/globals"
require "script/node/effect"
require "script/node/node"
require "script/tools"

Entity = Node{
    classType = "entity",
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
        item = deepcopy(item)
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
        
        self:update()
    end,
    
    unequip = function(self, a)
        if type(a) == "string" then slot = a
        elseif type(a) == "table" then slot = a:get("slot") end
        
        if self:isEquipped(slot) then
            self.equipment[slot]:update()
            self:addItem(self.equipment[slot])
            self.equipment[slot] = ""
        end
        
        self:update()
    end,
    
    isEquipped = function(self, slot)
        return self.equipment[slot] and self.equipment[slot] ~= ""
    end,
    
    
    -- BATTLING / STATS
    
    
    update = function(self)
        local stats = {}
        local statChanges = {}
        for k, v in pairs(self:get("stats")) do statChanges[k] = {["+"] = 0, ["*"] = 100, ["="] = false} end
        
        for k, v in pairs(self:get("equipment")) do
            if v ~= "" and v:get("stats") then
                for _, stat in pairs(v:get("stats")) do table.insert(stats, stat) end
            end
        end
        
        for k, v in pairs(stats) do
            if v.opp == "=" then
                if statChanges[v.stat]["="] and v.value < statChanges[v.stat]["="] then
                    statChanges[v.stat]["="] = v.value end
            elseif v.opp == "*" then
                statChanges[v.stat]["*"] = statChanges[v.stat]["*"] + v.value
            else
                statChanges[v.stat]["+"] = statChanges[v.stat]["+"] + v.value
            end
        end
        
        for k, v in pairs(statChanges) do
            local baseStat = self:get("baseStats")[k]
            local stat = baseStat
            stat = stat + v["+"]
            stat = stat + math.ceil(baseStat * ((v["*"] - 100) / 100))
            if v["="] then stat = v["="] end
            
            self:get("stats")[k] = stat
        end
        
        if self:get("hp") > self:get("stats").maxHp then self:set("hp", self:get("stats").maxHp) end
        if self:get("mp") > self:get("stats").maxMp then self:set("mp", self:get("stats").maxMp) end
    end,
    
    attack = function(self, target)
        local weapon = self.equipment["weapon"]
        local effect = ""
        local text = ""
        
        if self:isEquipped("weapon") then
            effect = weapon:get("effect")
            local verb = weapon:get("verb")
            if verb == "" then verb = self:get("attackText") end
            
            text = "%s %s %s, " % {self:get("name"), verb, target:get("name")}
        else
            effect = {Effect{hp={-1, -1}}}
            text = "%s %s %s, " % {self:get("name"), self:get("attackText"), target:get("name")}
        end
        
        return target:defend(self, effect, text)
    end,
    
    defend = function(self, source, effect, text)
        local prefix = text
        local text = {}
        
        for k, e in ipairs(effect) do
            local line = prefix
            local hp = 0
            local mp = 0
            local passive = false
            
            if e:get("hp") then
                hp = rand(e:get("hp"))
            elseif e:get("mp") then
                mp = rand(e:get("mp"))
            end
            
            if hp < 0 and mp < 0 then line = line.."dealing <hp>{hp} %d {white}and <mp>{mp} %d {white}damage." % {math.abs(hp), math.abs(mp)}
            elseif hp < 0 then line = line.."dealing <hp>{hp} %d {white}damage." % {math.abs(hp)}
            elseif mp < 0 then line = line.."dealing <hp>{hp} %d {white}damage." % {math.abs(mp)} end
            
            if hp > 0 and mp > 0 then line = line.."healing <hp>{hp} %d {white}and <mp>{mp} %d{white}." % {math.abs(hp), math.abs(mp)}
            elseif hp > 0 then line = line.."healing <hp>{hp} %d{white}." % {math.abs(hp)}
            elseif mp > 0 then line = line.."healing <hp>{hp} %d{white}." % {math.abs(mp)} end
            
            self:add("hp", hp)
            self:add("mp", mp)
            
            table.insert(text, line)
        end
        
        return text
    end,
    
    
    -- CLASS FUNCTION OVERRIDES
    
    
    init = function(self)
        for k, v in ipairs(equipment) do
            self.equipment[v] = ""
        end
        
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
        self.stats["maxMp"] = 10
        self.baseStats["maxMp"] = 10
        self.mp = 10
    end,
    
    get = function(self, key)
        if key == "title" then
            local class = ""
            if self:get("class") then class = " "..self:get("class") end
            return "%s [Lvl %d%s]" % {self:get("name"), self:get("level"), class}
        else
            return self[key]
        end
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