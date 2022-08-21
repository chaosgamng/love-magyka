require "script/node/item"
require "script/node/node"
require "script/tools"

Town = Node{
    name = "Town",
    stores = {},
    storeTypes = {},
    storeNames = {},
    
    export = function(self)
        local exportStores = {}
        
        for k, v in pairs(self.stores) do exportStores[k] = v:export() end
        
        exportSelf = export(self)
        exportSelf.stores = deepcopy(exportStores)
        
        return exportSelf
    end,
}

Store = Node{
    name = "Store",
    items = {},
    forge = false,
    enchant = false,
    rest = false,
    dine = false,
    sell = false,
    cure = false,
    bless = false,
    
    export = function(self)
        local exportItems = {}
        
        for k, v in pairs(self.items) do exportItems[k] = v:export() end
        
        exportSelf = export(self)
        exportSelf.items = deepcopy(exportItems)
        
        return exportSelf
    end,
}

function newTown(arg)
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

function newStore(arg, town)
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