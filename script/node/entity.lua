require "script/globals"
require "script/node/effect"
require "script/node/item"
require "script/node/loot"
require "script/node/node"
require "script/node/recipe"
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
    
    attackEffect = nil,
    attackText = "attacks",
    
    stats = {},
    baseStats = {},
    
    equipment = {},
    inventory = {},
    
    arts = {},
    
    recipes = {},
    
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
            if v[1]:get("stackable") and v[1]:get("name") == name then
                quantity = v[2]
                break
            elseif not v[1]:get("stackable") and type(item) == "string" then
                quantity = quantity + 1
            elseif not v[1]:get("stackable") and type(item) == "table" then
                quantity = 1
                break
            end
        end
        
        return quantity
    end,
    
    addItem = function(self, item, quantity)
        if item then
            local quantity = quantity or 1
            item = deepcopy(item)
            item:update()
            
            -- Add item
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
                for i = 1, quantity do table.insert(self.inventory, {deepcopy(item), 1}) end
            end
            
            -- Add recipes
            if recipes[item.name] then
                for k, v in ipairs(recipes[item.name]) do
                    local recipeFound = false
                    for _, recipe in ipairs(self.recipes) do
                        if recipe:get("name") == v then
                            recipeFound = true
                            break
                        end
                    end
                    
                    if not recipeFound then table.insert(self.recipes, newRecipe(v)) end
                end
            end
        end
    end,
    
    removeItem = function(self, item, quantity)
        local quantity = quantity or 1
        
        local name = item
        if type(item) == "table" then name = item:get("name") end
        
        if quantity > self:numOfItem(item) then quantity = self:numOfItem(item) end
        
        if self:numOfItem(item) > 0 then
            if type(item) == "string" or item:get("stackable") then
                for k, v in ipairs(self.inventory) do
                    if v[1]:get("name") == name then
                        if quantity == v[2] then table.remove(self.inventory, k)
                        else v[2] = v[2] - quantity end
                        break
                    end
                end
            else
                for k, v in ipairs(self.inventory) do
                    if v[1] == item then
                        table.remove(self.inventory, k)
                        break
                    end
                end
            end
        end
    end,
    
    equip = function(self, item)
        local slot = item:get("slot")
        if slot then
            item:update()
            
            self:unequip(slot)
            self.equipment[slot] = item
            self:removeItem(item)
            
            self:update()
        end
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
        local text = {}
        
        if self:isEquipped("weapon") then effect = self:get("equipment").weapon:get("effect")
        else effect = {newEffect(self:get("attackEffect"))} end
        
        for k, e in ipairs(effect) do
            if e.hp then
                e.hp[1] = e.hp[1] - self:get("stats").strength
                e.hp[2] = e.hp[2] - self:get("stats").strength
            end
            
            if e.crit == nil then e.crit = e.critBonus + self:get("stats").crit end
            
            table.insert(text, e:use(self, target))
        end
        
        return text
    end,
    
    defend = function(self, source, effect, text)
        local prefix = text
        local text = {}
        
        for k, e in ipairs(effect) do
            local line = prefix
            local hp = 0
            local mp = 0
            local passive = false
            
            if e:get("hp") then hp = rand(e:get("hp")) end
            if e:get("mp") then mp = rand(e:get("mp")) end
            
            local miss = false
            local dodge = false
            
            if source ~= self or (source == self and (hp < 0 or mp < 0)) then
                if rand(1, 100) < 100 - source:get("stats").hit then
                    miss = true
                    line = line.."but %s dodges." % {self:get("name")}
                elseif rand(1, 100) < self:get("stats").dodge then
                    dodge = true
                    line = line.."but misses."
                end
            end
            
            local crit = 1
            if hp < 0 or mp < 0 then
                local variance = rand(80, 120) / 100
                
                if rand(1, 100) < source:get("stats").crit - self:get("stats").resistance then
                    crit = crit + (source:get("stats").critDamage / 100)
                end
                
                if hp < 0 then
                    hp = math.floor((hp + (self:get("stats").armor / 2) + self:get("stats").vitality) * crit * variance)
                    if hp > -1 then hp = -1 end
                end
                
                if mp < 0 then
                    mp = math.floor((mp + self:get("stats").vitality) * crit * variance)
                    if mp > -1 then mp = -1 end
                end
            end
            
            if not dodge and not miss then
                if crit > 1 then crit = " critical "
                else crit = "" end
                
                if hp < 0 and mp < 0 then line = line.."dealing <hp>{hp} %d {white}and <mp>{mp} %d {white}%sdamage." % {math.abs(hp), crit, math.abs(mp)}
                elseif hp < 0 then line = line.."dealing <hp>{hp} %d {white}%sdamage." % {math.abs(hp), crit}
                elseif mp < 0 then line = line.."dealing <mp>{mp} %d {white}%sdamage." % {math.abs(mp), crit} end
                
                if hp > 0 and mp > 0 and self:get("hp") == self:get("stats").maxHp and self:get("mp") == self:get("stats").maxMp then
                    hp = 0
                    mp = 0
                    line = line.."doing nothing."
                elseif hp > 0 and mp == 0 and self:get("hp") == self:get("stats").maxHp then
                    hp = 0
                    line = line.."doing nothing."
                elseif mp > 0 and hp == 0 and self:get("mp") == self:get("stats").maxMp then
                    mp = 0
                    line = line.."doing nothing."
                else
                    if hp > 0 then hp = self:get("stats").maxHp - self:get("hp") end
                    if mp > 0 then mp = self:get("stats").maxMp - self:get("mp") end
                    
                    if hp > 0 and mp > 0 then line = line.."healing <hp>{hp} %d {white}and <mp>{mp} %d{white}." % {math.abs(hp), math.abs(mp)}
                    elseif hp > 0 then line = line.."healing <hp>{hp} %d{white}." % {math.abs(hp)}
                    elseif mp > 0 then line = line.."healing <mp>{mp} %d{white}." % {math.abs(mp)} end
                end
                
                self:add("hp", hp)
                self:add("mp", mp)
            end
            
            table.insert(text, line)
        end
        
        return text
    end,
    
    
    -- CLASS FUNCTION OVERRIDES
    
    
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
            
            while self.xp >= self.maxXp do
                self.xp = self.xp - self.maxXp
                self:levelUp()
            end
        else
            self[key] = value
        end 
    end,
}

function newEntity(arg)
    if type(arg) == "string" then
        local entity = newEntity(require("data/entity")[arg])
        
        if entity then
            entity.name = arg
            return entity
        else
            return Entity{name=arg}
        end
    elseif type(arg) == "table" then
        local entity = deepcopy(arg)
        
        if entity.inventory then
            for k, v in ipairs(entity.inventory) do
                v[1] = newItem(v[1])
            end
        else
            entity.inventory = {}
        end
                
        if entity.drops then
            if entity.drops.drops ~= nil then entity.drops = {entity.drops} end
            
            for k, v in pairs(entity.drops) do
                table.insert(entity.inventory, newLoot(v))
            end
        end
        
        if entity.equipment then
            for k, v in pairs(entity.equipment) do
                if v ~= "" then entity.equipment[k] = newItem(entity.equipment[k]) end
            end
        else
            entity.equipment = {}
            for k, v in ipairs(equipment) do entity.equipment[v] = "" end
        end
        
        if entity.recipes then
            for k, v in ipairs(entity.recipe) do
                entity.recipe[k] = newRecipe(v)
            end
        end
        
        if entity.arts then
            for k, v in ipairs(entity.arts) do
                entity.art[k] = newEffect(v)
            end
        end
        
        if entity.attackEffect then entity.attackEffect = newEffect(entity.attackEffect)
        else entity.attackEffect = newEffect({hp={-1, -1}}) end
        
        local defaultStats = {
            maxHp = 7,
            maxMp = 10,
            hit = 95,
            dodge = 4,
            crit = 4,
            critDamage = 100,
        }
        
        if entity.baseStats then
            for k, v in pairs(defaultStats) do
                if not entity.baseStats[k] then entity.baseStats[k] = v end
            end
        else
            entity.baseStats = defaultStats
        end
        
        entity.stats = {}
        
        for k, v in ipairs(stats) do
            if entity.baseStats[v] then
                entity.stats[v] = entity.baseStats[v]
            else
                entity.stats[v] = 0
                entity.baseStats[v] = 0
            end
        end
        
        for k, v in ipairs(extraStats) do
            if entity.baseStats[v] then
                entity.stats[v] = entity.baseStats[v]
            else
                entity.stats[v] = 0
                entity.baseStats[v] = 0
            end
        end
        
        if not entity.hp then entity.hp = entity.baseStats.maxHp end
        if not entity.mp then entity.mp = entity.baseStats.maxMp end
        
        entity = Entity(entity)
        entity:update()
        
        return entity
    end
end