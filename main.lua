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

keyLShift = false
keyRShift = false
keyShift = false

function love.load()
    font = love.graphics.newImageFont("image/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    math.randomseed(os.time())
    
    player:addItem(newItem("Throwing Knife"), 100)
    player:addItem(newItem("Health Potion"), 100)
    
    player:equip(newItem("Chestplate"))
end

function love.keyreleased(key)
    if key == "lshift" then keyLShift = false end
    if key == "rshift" then keyRShift = false end
end

function love.keypressed(key)
    if key == "`" then console = not console end
    if key == "lshift" then keyLShift = true end
    if key == "rshift" then keyRShift = true end
    if not console then screen.key = key end
    
    if console then
        if ("abcdefghijklmnopqrstuvwyz1234567890,"):find(key) then
            if keyShift then command = command..key:upper()
            else command = command..key end
        elseif key == "space" then command = command.." "
        elseif key == "backspace" then 
            if #command > 1 then command = command:sub(1, #command - 1)
            elseif #command == 1 then command = "" end
        elseif key == "return" then
            command = split(command, " ", 1)
            local word = command[1]
            local args = split(command[2], ", ")
            
            if word == "battle" then
                if args[1] then
                    screen.turn = "player"
                    screen:down("battle")
                    screen:set("enemy", {newEntity(args[1])}, "battle")
                end
            elseif word == "equip" then
                if args[1] then
                    player:equip(newItem(args[1]))
                end
            elseif word == "give" then
                if args[1] then
                    local quantity = 1
                    if #args > 1 then quantity = tonumber(args[2]) end
                    
                    player:addItem(newItem(args[1]), quantity)
                end
            elseif word == "heal" then
                player:set("hp", 999999999)
                player:set("mp", 999999999)
            elseif word == "editor" then
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
    keyShift = keyLShift or keyRShift
    
    screen:update(0)
    
    if console then
        draw:rect("gray18", 1, 1, screen.width, 20)
        draw:rect("gray48", 1, 21, screen.width, 1)
        draw:text(command, 2, 21)
    end
    
    love.timer.sleep(1/60)
end