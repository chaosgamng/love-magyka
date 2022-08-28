require "script/node/art"
require "script/node/effect"
require "script/node/entity"
require "script/node/item"
require "script/node/loot"
require "script/node/map"
require "script/node/node"
require "script/node/recipe"
require "script/node/town"
require "script/node/world"
require "script/tools"

json = require("library/json")


-- Misc Functions

function setupString(arg, t) -- Loads an item from a table from the database
    local obj = nil
    local query = db:prepare("select * from %s where name=\"%s\"" % {t, arg})
    for row in query:nrows() do obj = row end
    return obj
end

function setupTable(arg) -- Automatically formats as much of the table from the database as possible
    for k, v in pairs(arg) do
        if v == "true" then arg[k] = true end
        if v == "false" then arg[k] = false end
    end
    
    return deepcopy(arg)
end


-- Object Generators

function newArt(arg) -- Unedited
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

function newEffect(arg)
    if type(arg) == "string" then
        local effect = newEffect(setupString(arg, "Effect"))
        
        if effect then return effect else return Effect{name=arg} end
    elseif type(arg) == "table" then
        local effect = setupTable(arg)
        
        
        -- Parse hp and mp effects
        
        if effect.hp and type(effect.hp) == "string" then effect.hp = json.decode(effect.hp) end
        if effect.mp and type(effect.mp) == "string" then effect.mp = json.decode(effect.mp) end
        
        
        -- Parse stat effects and autoformat
        
        if effect.stats then
            effect.stats = json.decode(effect.stats)
            
            for k, v in pairs(effect.stats) do
                if type(v) ~= "table" then effect.stats[k] = {stat = k, value = v, opp = "+"} end
            end
        end
        
        
        -- Parase passive effects and autoformat
        
        if effect.passive then
            if effect.passive == true then
                if effect.crit == nil then effect.crit = 0 end
                if effect.hit == nil then effect.hit = 0 end
                if effect.noDodge == nil then effect.noDodge = true end
            else
                if type(effect.passive) == "string" then effect.passive = json.decode(effect.passive) end
                
                if type(effect.passive) == "string" or effect.passive[1] == nil then
                    effect.passive = {effect.passive}
                end
                
                for k, v in ipairs(effect.passive) do
                    effect.passive[k] = newEffect(v)
                end 
            end
        end
        
        return Effect(effect)
    end
end

function newEntity(arg)
    if type(arg) == "string" then
        local entity = newEntity(setupString(arg, "Entity"))
        
        if entity then return entity
        else return Entity{name=arg} end
    elseif type(arg) == "table" then
        local entity = setupTable(arg)
        
        --[[if entity.inventory then
            for k, v in ipairs(entity.inventory) do
                v[1] = newItem(v[1])
            end
        else
            entity.inventory = {}
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
        end]]--
        
        
        -- Parse attack effect
        
        if entity.attackEffect then
            entity.attackEffect = newEffect(json.decode(entity.attackEffect))
        else
            entity.attackEffect = newEffect({hp={-1, -1}})
        end
        
        
        -- Parse entity stats and autofill from defaults
        
        local defaultStats = {
            maxHp = 7,
            maxMp = 10,
            hit = 95,
            dodge = 4,
            crit = 4,
            critDamage = 100,
        }
        
        if entity.stats then -- Load stats for entities that are enemies
            entity.stats = json.decode(entity.stats)
            entity.baseStats = entity.stats
        end
        
        if entity.baseStats then
            if entity.baseStats.maxHp == nil and entity.hp then entity.baseStats.maxHp = entity.hp end
            if entity.baseStats.maxMp == nil and entity.mp then entity.baseStats.maxMp = entity.mp end
            for k, v in pairs(defaultStats) do
                if not entity.baseStats[k] then entity.baseStats[k] = v end
            end
        else
            entity.baseStats = defaultStats
        end
        
        entity.stats = {}
        
        
        -- Autofill missing stats
        
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
        
        
        -- Set entity hp and mp to max if not specified
        
        if not entity.hp then entity.hp = entity.baseStats.maxHp end
        if not entity.mp then entity.mp = entity.baseStats.maxMp end
        
        
        -- Parse drops for enemies
        
        if entity.drops then
            entity.drops = json.decode(entity.drops)
            
            entity.inventory = {}
            for k, v in pairs(entity.drops) do
                table.insert(entity.inventory, newLoot(v))
            end
        end
        
        entity = Entity(entity)
        entity:update()
        return entity
    end
end

function newItem(arg)
    if type(arg) == "string" then
        local item = newItem(setupString(arg, "Item"))
        
        if item then return item
        else return Item{name=arg} end
    elseif type(arg) == "table" then
        local item = deepcopy(arg)
        
        
        -- Parse description into table by splitting by newlines
        
        if item.description then item.description = split(item.description, "\13\n") end
        
        
        -- Autoformat stackable bool
        
        if item.equipment then item.stackable = false end
        
        
        -- Parse stats and autofill
        
        if item.stats then
            item.stats = json.decode(item.stats)
            
            for k, v in pairs(item.stats) do
                if type(v) ~= "table" then item.stats[k] = {stat = k, value = v, opp = "+"} end
            end
        end
        
        
        -- Parse effects and autoformat verbs if nil
        
        if item.effect then
            item.effect = json.decode(item.effect)
            if item.effect[1] == nil then item.effect = {item.effect} end
            
            for k, v in ipairs(item.effect) do
                if v.verb == nil then
                    if item.consumable then v.verb = "uses"
                    elseif item.equipment then v.verb = "attacks" end
                end
                item.effect[k] = newEffect(v)
            end
        end
        
        item = Item(item)
        item:update()
        return item
    end
end

function newLoot(arg) -- Unedited
    if type(arg) == "string" then
        local loot = require("data/loot")[arg]
        loot.name = arg
        return newLoot(loot)
    elseif type(arg) == "table" then
        local loot = deepcopy(arg)
        
        loot = Loot(loot)
        return loot
    end
end

function newMap(arg) -- Unedited
    if type(arg) == "string" then
        local map = Map{}
        
        local tileImage = love.image.newImageData("map/%s.png" % {arg})
        local collisionImage = love.image.newImageData("map/%s Collision.png" % {arg})
        local groupsImage = love.image.newImageData("map/%s Groups.png" % {arg})
        map.data = require("map/"..arg)
        
        for y = 0, tileImage:getHeight() - 1 do
            local tileRow = {}
            local collisionRow = {}
            local groupsRow = {}
            
            for x = 0, tileImage:getWidth() - 1 do
                local r, g, b, a = tileImage:getPixel(x, y)
                table.insert(tileRow, {r, g, b})
                
                r, g, b, a = collisionImage:getPixel(x, y)
                table.insert(collisionRow, r == 1)
                
                r, g, b, a = groupsImage:getPixel(x, y)
                table.insert(groupsRow, r * 255)
            end
            
            table.insert(map.tiles, tileRow)
            table.insert(map.collision, collisionRow)
            table.insert(map.groups, groupsRow)
        end
        
        map.data.portalTiles = {}
        for k, v in ipairs(map.data.portals) do
            if v.town then
                portal = v
                map.data.portalTiles[v.y] = {}
                map.data.portalTiles[v.y+1] = {}
                map.data.portalTiles[v.y][v.x] = portal
                map.data.portalTiles[v.y][v.x+1] = portal
                map.data.portalTiles[v.y+1][v.x] = portal
                map.data.portalTiles[v.y+1][v.x+1] = portal
            end
        end
        
        return map
    end
end

function newRecipe(arg) -- Unedited
    if type(arg) == "string" then
        local recipe = require("data/recipe")[arg]
        recipe.name = arg
        return newRecipe(recipe)
    elseif type(arg) == "table" then
        local recipe = deepcopy(arg)
        
        if recipe.item == nil then recipe.item = newItem(recipe.name) end
        
        recipe = Recipe(recipe)
        return recipe
    end
end

function newStore(arg, town) -- Unedited
    if type(arg) == "string" then
        local store = newStore(require("data/town")[town]["stores"][arg])
        
        if store.items then
            for k, v in pairs(store.items) do store.items[k] = newItem(v) end
        end
        
        if store then return store else return Store{} end
    elseif type(arg) == "table" then
        local store = deepcopy(arg)
        
        if store.items then
            for k, v in pairs(store.items) do store.items[k] = newItem(v) end
        end
        
        return Store(store)
    end
end

function newTown(arg) -- Unedited
    if type(arg) == "string" then
        local town = newTown(require("data/town")[arg])
        
        if town then return town else return Town{} end
    elseif type(arg) == "table" then
        local town = deepcopy(arg)
        
        town.storeNames = {}
        town.storeTypes = {}
        
        if town.stores then
            for k, v in pairs(town.stores) do
                town.stores[k] = newStore(v, town.name)
                table.insert(town.storeNames, town.stores[k].name)
                table.insert(town.storeTypes, k)
            end
        end
        
        return Town(town)
    end
end

function newWorld(arg)
    world = World{}
    world.player = newEntity{name="Player"}
    world.player:update()
    
    return world
end