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