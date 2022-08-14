require "script/entity"
require "script/node"

World = Node{
    player = Entity{name="Player"},
    enemy = Entity{name="Green Slime"},
    
    init = function(self)
        self.player:init()
        self.enemy:init()
    end,
}