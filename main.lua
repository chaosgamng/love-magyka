require "script/color"
require "script/entity"
require "script/draw"
require "script/tools"

hp = "icon/hp"
mp = "icon/mp"
xp = "icon/xp"
gp = "icon/gp"

screen = {
    width = math.floor(love.graphics.getWidth() / 10),
    height = math.floor(love.graphics.getHeight() / 20),
    
    current = "camp",
    key = "",
    
    update = function(self, dt)
        self[self.current](self)
    end,
    
    
    -- SCREENS --
    
    
    camp = function(self)
        draw:initScreen(38, "image/camp")
        
        draw:mainStats(player)
        draw:newline()
        
        draw:options({"Map", "Character", "Rest", "Options"})
        draw:newline()
        
        draw:text("- Press a letter to select an option.")
        
        if self.key == "c" then self.current = "character" end
    end,
    
    character = function(self)
        draw:init(38, "image/character")
        draw:mainStats(player)
        draw:newline()
        
        draw:options({"Inventory", "Equipment", "Crafting", "Arts", "Quests", "Stats"})
        draw:newline()
        
        draw:text("- Press a letter to select an option.")
    end,
}

function love.load()
    font = love.graphics.newImageFont("img/imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"|")
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(color.gray18)
    
    player = Entity{}
end

function love.keypressed(key)
    screen.key = key
end

function love.update(dt)
    
end

function love.draw()
    screen:update(0)
end