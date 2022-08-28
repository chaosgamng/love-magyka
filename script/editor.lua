require "script/color"
require "script/draw"
require "script/globals"
require "script/node/entity"
require "script/node/item"
require "script/screen"
require "script/tools"

return {
    editorMain = function(self)
        draw:initScreen(38, "screen/crafting")
        
        draw:text("Select a category to edit.")
        
        draw:newline()
        draw:optionsNumbered({"Art", "Enemy", "Item", "Effect", "Town", "Quest"})
        
        if self.key == "1" then self.editorType = "art"
        elseif self.key == "2" then self.editorType = "enemy"
        elseif self.key == "3" then self.editorType = "item"
        elseif self.key == "4" then self.editorType = "effect"
        elseif self.key == "5" then self.editorType = "town"
        elseif self.key == "6" then self.editorType = "quest" end
        
        if self.editorType then self:down("editorList") end
    end,
    
    editorList = function(self)
        draw:initScreen(38, "screen/crafting")
        
        local dict = require("data/"..self.editorType)
        local list = {}
        
        for k, v in pairs(dict) do
            table.insert(list, k)
        end
        
        table.sort(list)
        
        self:pages(
            list,
            function(element) return element end,
            function(element)
                self:down("editorElement")
                self:set("element", dict[element], "editorElement")
                table.insert(self:get("editorElement"), {element, dict[element]})
            end,
            function() self:up() end
        )
    end,
    
    editorElement = function(self)
        draw:initScreen(38, "screen/crafting")
        
        local element = self:get("element")
        
        local list = {}
        for k, v in pairs(element) do
            table.insert(list, {k, v})
        end
        
        self:pages(
            list,
            function(element) return element[1] end,
            function(element)
                if type(element[2]) == "table" then
                    table.insert(self:get("editorElement"), element)
                    self:set("element", element[2])
                else
                    self:down("editorElementValue")
                    self:set("element", element[2])
                end
            end,
            function()
                if #self:get("editorElement") > 1 then
                    self:set("element", table.remove(self:get("editorElement"), -1)[2])
                else
                    self:up()
                end
            end
        )
    end,
    
    editorElementValue = function(self)
        draw:initScreen(38, "screen/crafting")
        local parent = self:get("editorElement", "editorElement")
        parent = parent[#parent]
        draw:text(parent[1])
        
        draw:newline()
        draw:text("Current value:")
        
        draw:newline()
        draw:text(self:get("element"))
        
        draw:newline()
        draw:text("New value:")
        
        draw:newline()
        draw:text(self:get("text"))
        
        if ("abcdefghijklmnopqrstuvwxyz1234567890,"):find(self.key) then
            if keyShift then self:set("text", self:get("text")..self.key:upper())
            else command = self:set("text", self:get("text")..self.key) end
        elseif self.key == "space" then self:set("text", self:get("text").." ")
        elseif self.key == "backspace" then 
            if #self:get("text") > 1 then self:set("text", self:get("text"):sub(1, #command - 1))
            elseif #self:get("text") == 1 then self:set("text", "") end
        end
    end,
}