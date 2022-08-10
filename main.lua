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
    
    pre = "title",
    current = "title",
    post = "title",
    branch = "",
    key = "",
    
    update = function(self, dt)
        if self.current ~= self.post then
            self.pre = self.current
            self.current = self.post
        end
        if self.key == "escape" then self.post = self.pre end
        
        self[self.current](self)
        
        self.key = ""
    end,
    
    
    -- SCREENS --
    
    
    title = function(self)
        draw:border(0)
        draw:top()
        
        magyka = {
            "  x*8888x.:d8888:.:d888b                                        <688889>                    ",
            " X'  98888X:`88888:`8888!                           8L           !8888!                     ",
            "X8x.  8888X   888X  8888!                          8888!   .dL   '8888   ..                 ",
            "X8888 X8888   8888  8888'    .uu689u.   .uu6889u.  `Y888k:*888.   8888 d888L    .uu689u.    ",
            "'*888 !8888  !888* !888*   .888`*8888* d888`*8888    8888  888!   8888`*88**  .888`*8888*   ",
            "  `98  X888  X888  X888    8888  8888  8888  8888    8888  888!   8888 .d*.   8888  8888    ",
            "   '   X888  X888  8888    8888  8888  8888  8888    8888  888!   8888~8888   8888  8888    ",
            "   dx .8888  X888  8888.   8888  8888  8888  8888    8888  888!   8888 '888&  8888  8888    ",
            " .88888888*  X888  X888X.  8888.:8888  888&.:8888   x888&.:888'   8888  8888. 8888.:8888    ",
            "  *88888*    *888  `8888'  *888*'*888' *888*'8888.   *88*' 888  '*888*' 8888* *888*'*888*   ",
            "                                            '*8888         88F                              ",
            "..................................... .d88!   `888 ..... .98' ............................  ",
            " ..................................... 9888o.o88' ..... ./' ............................... ",
            "  ..................................... *68889*` ..... ~` ..... By Vincent G, aka Mutater ..",
        }
        
        for i = 1, 14 do
            draw:text(magyka[i])
        end
        
        draw:newline()
        draw:options({"New Game", "Continue", "Options", "Quit"})
        
        if self.key == "n" then self.post = "camp"
        elseif self.key == "c" then self.post = "camp"
        elseif self.key == "q" then love.event.quit() end
    end,
    
    map = function(self)
        self.pre = "map"
        draw:initScreen(38)
        
        draw:text("Ain't got nothin' here yet bruh.")
        
        draw:newline()
        draw:options({"Camp"})
        
        draw:newline()
        draw:text("- Press a letter to select an option.")
        
        if self.key == "c" then self.post = "camp" end
    end,
    
    camp = function(self)
        self.pre = "map"
        draw:initScreen(38, "image/camp")
        
        draw:mainStats(player)
        
        draw:newline()
        draw:options({"Character", "Rest", "Options"})
        
        draw:newline()
        draw:text("- Press a letter to select an option.")
        
        if self.key == "c" then self.post = "character" end
    end,
    
    character = function(self)
        self.pre = "camp"
        draw:initScreen(38, "image/character")
        
        draw:mainStats(player)
        
        draw:newline()
        draw:options({"Inventory", "Equipment", "Crafting", "Arts", "Quests", "Stats"})
        
        draw:newline()
        draw:text("- Press a letter to select an option. Press ESC to go back.")
        
        if self.key == "c" then
            self.post = "crafting"
            self.branch = "character"
        end
    end,
    
    crafting = function(self)
        self.pre = self.branch
        draw:initScreen(38, "image/crafting")
        
        draw:text("Please purchase the crafting DLC for $99.99!")
        
        draw:newline()
        draw:text("- Press ESC to go back.")
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