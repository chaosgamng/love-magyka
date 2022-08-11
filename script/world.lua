require "script/entity"
require "script/node"

World = Node{
    player = Entity{name="Player"},
    enemy = Entity{name="Enemy"},
}