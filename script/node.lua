function Node(class)
    class.add_component = function(self, name, component)
        if self.components == nil then self.components = {} end
        
        table.insert(self.components, name)
        self[name] = component
    end
    class.update_components = function(self, dt)
        for _, v in pairs(self.components) do
            if self[v].update ~= nil then self[v]:update(dt) end
        end
    end
    class.draw_components = function(self)
        for _, v in pairs(self.components) do
            if self[v].draw ~= nil then self[v]:draw() end
        end
    end
    
    if not class.update then
        class.update = function(self, dt) self:update_components(dt) end
    end
    if not class.draw then
        class.draw = function(self) self:draw_components() end
    end
    if not class.init then
        class.init = function(self) return nil end
    end
    
    if not class.get then
        class.get = function(self, key) return self[key] end
    end
    if not class.set then
        class.set = function(self, key, value) self[key] = value end
    end
    if not class.add then
        class.add = function(self, key, value) self:set(key, self:get(key) + value) end
    end
    if not class.multiply then
        class.multiply = function(self, key, value, round)
            value = self:get(key) * value
            if round == "ceil" then self:set(key, math.ceil(value))
            elseif round == "floor" then self:set(key, math.floor(value))
            else self:set(key, value) end
        end
    end
    if not class.divide then
       class.divide = function(self, key, value, round)
            value = self:get(key) / value
            if round == "ceil" then self:set(key, math.ceil(value))
            elseif round == "floor" then self:set(key, math.floor(value))
            else self:set(key, value) end
        end
    end
    
    class:init()
    
    return setmetatable(class, 
             { __call = function(self, init)
                           return setmetatable(init or {},
                                               { __index = class })
                        end })
end