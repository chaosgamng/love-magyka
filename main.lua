require "library/sqlite3"
db = assert(sqlite3.open("data/data.db"))

require "script/color"
require "script/dev"
require "script/draw"
require "script/generator"
require "script/globals"
require "script/screen"
require "script/tools"

-- TODO

--[[
 
 - MINIMUM VIABLE BUILD -
 
 * Add submap teleportation and map entities.
 * Saving / Loading (Loading is basically in place).
 * Give dev toggles and add more dev commands for easier playtesting.
 * Crafting of specific types in blacksmith etc.
 * Clear up inconsistent input hints.
 * Add headers or some sort of description for every page.
 * Add art for every page.
 * Curing and blessing from the church.
 * Quests.
 * Generic end boss for the demo.
 
 - EXTRA -
 
 * Elemental attacks and resistances.
 * Ability to choose an item from the inventory to use in:
   - Item and Art application.
   - Selection for what equipment to use in recipes.
 * Procedurally generated loot.
 * Enchanting at the arcanist.
 * Finish the editor for items, enemies, etc.
 * Fix diagonal collision cases.
 * Figure out how to have columns in the screen.pages function.
 * Random events on map screen.
 * Map painter.
   - Palettes
   - Pencil, Fill, Line
   - Undo and Redo
   - Exporting
   - Map modes
   - Entity placement
   - Entity customization

]]--


world = newWorld()
player = world:get("player")

console = false
local command = ""

keyLShift = false
keyRShift = false
keyShift = false
input = {
    up = {"up", false},
    down = {"down", false},
    left = {"left", false},
    right = {"right", false},
}

backspace = false

local keyTimer = 0
local keyTimerDefault = 0.1

function love.load()
    font = love.graphics.newImageFont("image/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|_")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    math.randomseed(os.time())
    
    devCommand("give Sword")
end

function love.keyreleased(key)
    if key == "lshift" then keyLShift = false end
    if key == "rshift" then keyRShift = false end
end

function love.keypressed(key)
    if key == "`" then
        console = not console
        love.keyboard.setKeyRepeat(console)
    end
    if key == "lshift" then keyLShift = true end
    if key == "rshift" then keyRShift = true end
    
    if not console then screen.key = key end
    
    if console then
        if ("abcdefghijklmnopqrstuvwxyz1234567890,"):find(key) then
            if keyShift then command = command..key:upper()
            else command = command..key end
        elseif key == "space" then command = command.." "
        elseif key == "backspace" then 
            if #command > 1 then command = command:sub(1, #command - 1)
            elseif #command == 1 then command = "" end
        elseif key == "escape" then
            command = ""
            console = false
        elseif key == "return" then
            devCommand(command)
            command = ""
            console = false
        end
    end
end

function love.update(dt)
    keyTimer = keyTimer + dt
    if keyTimer >= keyTimerDefault then
        keyTimer = keyTimer - keyTimerDefault
        for k, v in pairs(input) do
            if love.keyboard.isScancodeDown(v[1]) then v[2] = true
            else v[2] = false end
        end
    end
    
    keyShift = keyLShift or keyRShift
end

function love.draw()
    collectgarbage("collect")
    screen:update(0)
    
    if console then
        draw:rect("gray18", 1, 1, screen.width, 20)
        draw:rect("gray48", 1, 21, screen.width, 1)
        draw:text(command, 2, 21)
        draw:text("_", 2 + #command, 21)
    end
    
    love.timer.sleep(1/30)
end