require "script/globals"

screen = {
    width = math.floor(love.graphics.getWidth() / 10),
    height = math.floor(love.graphics.getHeight() / 20),
    
    current = "title",
    post = "title",
    branch = {},
    
    key = "",
    turn = "player",
    text = "",
    
    update = function(self, dt)
        self[self.current](self)
        self.key = ""
    end,
    
    up = function(self)
        self.current = self.branch[#self.branch]
        table.remove(self.branch)
    end,
    
    upPast = function(self, name)
        
    end,
    
    down = function(self, name)
        table.insert(self.branch, self.current)
        self.current = name
    end,
    
    
    -- SCREENS --
    
    
    title = function(self)
        draw:border(0)
        draw:top()
        
        local magyka = {
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
            draw:text(magyka[i], {0.15, 0.55 - i/50, 0.5 + i/25})
        end
        
        draw:newline()
        draw:options({"New Game", "Continue", "Options", "Quit"})
        
        if self.key == "n" then self:down("map")
        elseif self.key == "c" then self:down("map")
        elseif self.key == "q" then love.event.quit() end
    end,
    
    map = function(self)
        draw:initScreen(38)
        
        draw:text("Ain't got nothin' here yet bruh.")
        
        draw:newline()
        draw:options({"Camp"})
        
        draw:newline()
        draw:text("- Press a letter to select an option.")
        
        if self.key == "c" then self:down("camp") end
    end,
    
    camp = function(self)
        draw:initScreen(38, "image/camp")
        
        draw:mainStats(player)
        
        draw:newline()
        draw:options({"Inventory", "Equipment", "Arts", "Crafting", "Quests", "Stats", "Options"})
        
        draw:newline()
        draw:text("- Press a letter to select an option.")
        
        if self.key == "i" then self:down("inventory")
        elseif self.key == "e" then self:down("equipment")
        elseif self.key == "c" then self:down("crafting")
        elseif self.key == "escape" then self:up() end
    end,
    
    inventory = function(self)
        draw:initScreen(38, "image/inventory")
        
        playerInventory = player:get("inventory")
        for k, v in ipairs(playerInventory) do
            if v[1]:get("stackable") then quantity = v[2]
            else quantity = 0 end
            
            draw:text("(%d) %s" % {k, v[1]:display(quantity)})
        end
        
        draw:newline()
        draw:text("- Press a number to select an option. Press ESC to go back.")
        
        if self.key == "escape" then self:up() end
    end,
    
    equipment = function(self)
        draw:initScreen(38, "image/equipment")
        
        playerEquipment = player:get("equipment")
        local i = 0
        for k, v in pairs(equipment) do
            i = i + 1
            
            draw:text("(%d) %s: %s" % {i, v, playerEquipment[v]})
        end
        
        draw:newline()
        draw:text("- Press a number to select an option. Press ESC to go back.")
        
        if self.key == "escape" then self:up() end
    end,
    
    
    -- BRANCH SCREENS
    
    
    battle = function(self)
        draw:initScreen(38, "enemy/"..enemy:get("name"))
        draw:hpmpAlt(enemy, draw.subLeft + 2, 3)
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        if self.turn == "player" then
            draw:options({"Fight", "Art", "Guard", "Item", "Flee"})
            
            if self.key == "f" then
                self.text = enemy:defend(player, player:attack())
                self.turn = "after player"
            end
        elseif self.turn == "after player" then
            draw:text(self.text)
            
            if self.key == "return" then
                if enemy:get("hp") <= 0 then self:down("victory")
                elseif player:get("hp") <= 0 then self:down("defeat")
                else self.turn = "enemy" end
            end
        elseif self.turn == "enemy" then
            draw:text("Enemy's turn")
            
            self.text = player:defend(enemy, enemy:attack())
            
            self.turn = "after enemy"
        elseif self.turn == "after enemy" then
            draw:text(self.text)
            
            if self.key == "return" then
                if enemy:get("hp") <= 0 then self:down("victory")
                elseif player:get("hp") <= 0 then self:down("defeat")
                else self.turn = "player" end
            end
        end
    end,
    
    battleArt = function(self)
    
    end,
    
    battleInventory = function(self)
    
    end,
    
    victory = function(self)
        draw:initScreen(38, "enemy/"..enemy:get("name"))
        draw:hpmpAlt(enemy, draw.subLeft + 2, 3)
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You won! Good job.")
        
        if self.key == "return" then self:up() end
    end,
    
    defeat = function(self)
        draw:initScreen(38, "enemy/"..enemy:get("name"))
        draw:hpmpAlt(enemy, draw.subLeft + 2, 3)
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You lost! Fuck you.")
        
        if self.key == "return" then self:up() end
    end,
    
    crafting = function(self)
        draw:initScreen(38, "image/crafting")
        
        draw:text("Please purchase the crafting DLC for $99.99!")
        
        draw:newline()
        draw:text("- Press ESC to go back.")
        
        if self.key == "escape" then self:up() end
    end,
}