require "script/color"
require "script/draw"
require "script/globals"
require "script/node/entity"
require "script/node/item"
require "script/node/world"
require "script/screen"
require "script/tools"

require "library/Tserial"

world = World{}
player = world:get("player")

console = false
editor = false
command = ""

function love.load()
    font = love.graphics.newImageFont("image/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    math.randomseed(os.time())
end

function love.keypressed(key)
    if key == "f1" then
        player:equip(newItem("Chestplate"))
    end
    
    if key == "f2" then
        print(dumpTable(player:get("stats")))
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
                screen:set("enemy", {Entity{name="Green Slime"}, Entity{name="Enemy"}, Entity{name="Orange Slime"}, Entity{name="Blue Slime"}}, "battle")
            elseif command == "heal" then
                player:set("hp", 999999999)
                player:set("mp", 999999999)
            elseif command == "editor" then
                for k, v in pairs(require("script/editor")) do screen[k] = v end
                screen.current = "editorMain"
                screen.branch = {}
                screen.bracnData = {}
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
    
    love.timer.sleep(1/60)
end