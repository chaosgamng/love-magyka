require "script/node/entity"
require "script/node/node"

World = Node{
    classType = "world",
    player = Entity{name="Player"},
	
	currentMap = "World",
	playerX = 113,
	playerY = 105,
}