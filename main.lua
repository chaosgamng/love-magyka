require "script/color"
require "script/draw"
require "script/entity"
require "script/globals"
require "script/item"
require "script/screen"
require "script/tools"
require "script/world"

world = World{}
player = world:get("player")
enemy = world:get("enemy")

material = Item{name="Crafting Material"}
potion = Item{name="Health Potion", consumable=true, effect=Effect{hp={2,9}}}
throwingKnife = Item{name="Throwing Knife", consumable=true, effect=Effect{hp={-4,-5}}}
sword = Item{name="Sword", equipment=true, slot="weapon", effect=Effect{hp={-2, -3}}}
chestplate = Item{name="Chestplate", equipment=true, slot="body", stats={armor=1, maxHp=1}}

function love.load()
    font = love.graphics.newImageFont("img/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    math.randomseed(os.time())
end

function love.keypressed(key)
    screen.key = key
    print(key)
    
    if key == "kp1" then screen:down("battle") end
    
    if key == "kp2" then
        player:addItem(material)
        player:addItem(potion)
        player:addItem(throwingKnife)
        player:addItem(sword)
        player:addItem(chestplate)
    end
    
    if key == "kp3" then player:equip(sword) end
    
    if key == "kpenter" then print(dump_table(image)) end
end

function love.draw()
    screen:update(0)
end