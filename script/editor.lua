require "script/color"
require "script/draw"
require "script/globals"
require "script/node/entity"
require "script/node/item"
require "script/screen"
require "script/tools"

return {
    editorMain = function(self)
        draw:initScreen(38, "screen/editor")
        
        draw:text("Select a category to edit.")
        
        draw:newline()
        draw:optionsNumbered({"Art", "Enemy", "Item", "Effect", "Town", "Quest"})
        
        if self.key == "1" then self.editorType = "art"
        elseif self.key == "2" then self.editorType = "enemy"
        elseif self.key == "3" then self.editorType = "item"
        elseif self.key == "4" then self.editorType = "effect"
        elseif self.key == "5" then self.editorType = "town"
        elseif self.key == "6" then self.editorType = "quest" end
        
        if self.editorType then self:down("editorList")
    end,
    
    editorList = function(self)
        draw:initScreen(38, "screen/editor")
    end,
}