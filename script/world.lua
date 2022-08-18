require "script/entity"
require "script/node"

World = Node{
    player = Entity{name="Player"},
	
	currentMap = "World",
	playerX = 113,
	playerY = 105,
}