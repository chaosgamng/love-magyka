require "script/node/entity"
require "script/node/node"

World = Node{
    classType = "world",
    player = newEntity({name="Player"}),
	
	currentMap = "World",
	playerX = 113,
	playerY = 105,
    
    init = function(self)
        self.player:update()
    end,
}