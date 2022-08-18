require "script/entity"
require "script/node"

World = Node{
    player = Entity{name="Player"},
    enemy = Entity{name="Green Slime"},
	
	currentMap = "World",
	playerX = 113,
	playerY = 105,
}