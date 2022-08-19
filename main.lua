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

console = false
command = ""

material = Item{name="Crafting Material"}
potion = Item{name="Health Potion", consumable=true, effect=Effect{hp={2,9}}, rarity="uncommon", target="entity"}
throwingKnife = Item{name="Throwing Knife", consumable=true, effect=Effect{hp={-4,-5}}, rarity="uncommon", target="entity"}
sword = Item{name="Sword", description="Wow, it's a sword! I've never seen one of these before!", equipment=true, slot="weapon", effect=Effect{hp={-10, -10}}}
chestplate = Item{name="Chestplate", equipment=true, slot="body", stats={armor=1, maxHp=1}}

function love.load()
    font = love.graphics.newImageFont("img/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    math.randomseed(os.time())
    
    -- TEMP
    
    player:addItem(material)
    player:addItem(potion)
    player:addItem(throwingKnife)
    player:addItem(sword)
    player:addItem(chestplate)
    player:equip(sword)
end

function love.keypressed(key)
    if key == "f1" then
        screen.item:set("value", 999)
    end
    
    if key == "f2" then
        print(screen:get("turn"), screen:get("stage"))
    end

    if key == "`" then console = not console end
    if not console then
        screen.key = key
    end
    
    if console then
        if ("abcdefghijklmnopqrstuvwyz"):find(key) then command = command..key
        elseif key == "backspace" then 
            if #command > 1 then command = command:sub(1, #command - 1)
            elseif #command == 1 then command = "" end
        elseif key == "return" then
            if command == "b" then
                screen.turn = "player"
                screen:down("battle")
                screen:set("enemy", {Entity{name="Green Slime"}, Entity{name="Enemy"}, Entity{name="Green Slime"}, Entity{name="Green Slime"}}, "battle")
            elseif command == "heal" then
                player:set("hp", 999999999)
                player:set("mp", 999999999)
            end
            
            command = ""
            console = false
        end
    end
end

function love.draw()
    screen:update(0)
    
    if console then
        draw:rect("gray18", 1, 1, screen.width, 20)
        draw:rect("gray48", 1, 21, screen.width, 1)
        draw:text(command, 2, 21)
    end
end