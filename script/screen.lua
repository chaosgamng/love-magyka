require "script/globals"
require "script/tools"

screen = {
    width = math.floor(love.graphics.getWidth() / 10),
    height = math.floor(love.graphics.getHeight() / 20),
    
    current = "title",
    post = "title",
    branch = {},
    branchData = {},
    branchDataDefaults = {
        inventory = {
            page = 1,
        },
        battle = {
            stage = "player",
            text = {""},
        },
        inspectItem = {
            stage = "input",
            option = "",
            text = "",
        },
        inspectItemEquipped = {
            stage = "input",
            option = "",
            text = "",
        },
    },
    
    key = "",
    item = nil,
    
    update = function(self, dt)
        self[self.current](self)
        self.key = ""
    end,
    
    up = function(self, args)
        args = args or {}
        self.branchData[self.current] = nil
        self.current = self.branch[#self.branch]
        updateTable(self.branchData[self.current], args)
        table.remove(self.branch)
    end,
    
    upPast = function(self, name, args)
        local nextScreen = ""
        args = args or {}
        
        for i = #self.branch, 1, -1 do
            nextScreen = self.branch[i]
            table.remove(self.branchData, nextScreen)
            table.remove(self.branch, i)
            if name == nextScreen then
                nextScreen = self.branch[i - 1]
                break
            end
        end
        
        self.current = nextScreen
        updateTable(self.branchData[self.current], args)
    end,
    
    down = function(self, name, args)
        args = args or {}
        self.branchData[name] = deepcopy(self.branchDataDefaults[name])
        updateTable(self.branchData[name], args)
        table.insert(self.branch, self.current)
        self.current = name
    end,
    
    get = function(self, key)
        return self.branchData[self.current][key]
    end,
    
    set = function(self, key, value)
        self.branchData[self.current][key] = value
    end,
    
    add = function(self, key, value)
        self.branchData[self.current][key] = self.branchData[self.current][key] + value
    end,
    
    
    -- SCREENS --
    
    
    title = function(self)
        draw:border(0)
        draw:top()
        
        local magyka = {
            "  x*8888x.:d8888:.:d888b                                        ,688889,                    ",
            " X'  98888X:`88888:`8888!                           8L           !8888!                     ",
            "X8x.  8888X   888X  8888!                          8888!   .dL   '8888   ..                 ",
            "X8888 X8888   8888  8888'    .uu689u.   .uu6889u.  `Y888k:*888.   8888 d888L    .uu689u.    ",
            "'*888 !8888  !888* !888*   .888`*8888* d888`*8888    8888  888!   8888`*88**  .888`*8888*   ",
            "  `98  X888  X888  X888    8888  8888  8888  8888    8888  888!   8888 .d*.   8888  8888    ",
            "   '   X888  X888  8888    8888  8888  8888  8888    8888  888!   8888=8888   8888  8888    ",
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
        local playerInventory = player:get("inventory")
        local start = (self:get("page") - 1) * 10 + 1
        local stop = self:get("page") * 10
        if stop > #playerInventory then stop = #playerInventory end
        
        
        if #playerInventory == 0 then
            draw:text("{gray68} - Empty")
        else
            for i = start, stop do
                local item = playerInventory[i]
                local inputTextPadding = #tostring(stop) - #tostring(i)
                local inputTextPrefix = tostring(i):sub(1, #tostring(i) - 1)
                local inputText = tostring(i):sub(-1)
                
                if item[1]:get("stackable") then quantity = item[2]
                else quantity = 0 end
                
                draw:text("%s(%d) %s" % {
                    inputTextPrefix, inputText, item[1]:display(quantity)
                }, 4 + inputTextPadding)
            end
        end
        
        local left = self:get("page") > 1
        local right = self:get("page") * 10 + 1 < #playerInventory
        
        draw:newline()
        draw:text("- Press a number to select an option. Press ESC to go back.")
        
        if isInRange(self.key, 1, #playerInventory - start + 1) then
            self.item = playerInventory[tonumber(self.key) + start - 1][1]
            self:down("inspectItem")
        elseif self.key == "left" and left then self:add("page", -1)
        elseif self.key == "right" and right then self:add("page", 1)
        elseif self.key == "escape" then self:up() end
    end,
    
    equipment = function(self)
        draw:initScreen(38, "image/equipment")
        
        playerEquipment = player:get("equipment")
        local i = 0
        for k, v in pairs(equipment) do
            i = i + 1
            
            if playerEquipment[v] ~= "" then draw:text("(%d) %s: %s" % {i, v, playerEquipment[v]:display(0)})
            else draw:text("(%d) %s: {gray48}None" % {i, v}) end
        end
        
        draw:newline()
        draw:text("- Press a number to select an option. Press ESC to go back.")
        
        if isInRange(self.key, 1, 8) then
            local item = playerEquipment[equipment[tonumber(self.key)]]
            
            if item ~= "" then
                self.item = item
                self:down("inspectItemEquipped")
            end
        elseif self.key == "escape" then self:up() end
    end,
    
    
    -- BRANCH SCREENS
    
    
    battle = function(self)
        draw:initScreen(38, "battle/default")
        draw:imageSide("enemy/"..enemy:get("name"))
        draw:hpmpAlt(enemy, draw.subLeft + 2, 3)
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        if self:get("stage") == "player" then
            draw:options({"Fight", "Art", "Guard", "Item", "Escape"})
            
            if self.key == "f" then
                table.insert(self:get("text"), player:attack(enemy))
                self:set("stage", "after player")
            end
        elseif self:get("stage") == "after player" then
            for k, v in self:get("text") do
                draw:text(v)
            end
            
            if self.key == "return" then
                if enemy:get("hp") <= 0 then self:down("victory")
                elseif player:get("hp") <= 0 then self:down("defeat")
                else self:set("stage", "enemy") end
            end
        elseif self:get("stage") == "enemy" then
            draw:text("Enemy's turn")
            
            table.insert(self:get("text"), enemy:attack(player))
            
            self:set("stage", "after enemy")
        elseif self:get("stage") == "after enemy" then
            draw:text(self.text)
            
            if self.key == "return" then
                if enemy:get("hp") <= 0 then self:down("victory")
                elseif player:get("hp") <= 0 then self:down("defeat")
                else self:set("stage", "player") end
            end
        end
    end,
    
    battleArt = function(self)
    
    end,
    
    battleItem = function(self)
    
    end,
    
    victory = function(self)
        draw:initScreen(38, "enemy/"..enemy:get("name"))
        draw:hpmpAlt(enemy, draw.subLeft + 2, 3)
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You won! Good job.")
        
        if self.key == "return" then self:upPast("battle") end
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
    
    inspectItem = function(self)
        draw:initScreen(38, "image/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        draw:item(self.item)
        
        if self:get("stage") == "input" then
            draw:newline()
            if self.item:get("consumable") then draw:options({"Use", "Discard"})
            elseif self.item:get("equipment") then draw:options({"Equip", "Discard"})
            else draw:options({"Discard"}) end
            
            if self.key == "e" and self.item:get("equipment") then
                player:equip(self.item)
                self.text = "Equipped "..self.item:display().."."
                self.option = "e"
                self:set("stage", "enter")
            elseif self.key == "u" and self.item:get("consumable") and self.item:get("target") ~= "enemy" then
                self.text = self.item:use(player)
                self.option = "u"
                self:set("stage", "enter")
            elseif self.key == "d" then
                player:removeItem(self.item)
                self.text = "Discarded "..self.item:display(1).."."
                self.option = "d"
                self:set("stage", "enter")
            elseif self.key == "escape" then self:up() end
        elseif self:get("stage") == "enter" then
            draw:newline()
            draw:text(self.text)
            
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "return" or self.key == "escape" then
                if ("eu"):find(self.option) then
                    if not self.item:get("infinite") then player:removeItem(self.item) end
                    
                    if player:numOfItem(self.item) == 0 then self:up()
                    else self:set("stage", "input") end
                else
                    self:up()
                end
            end
        end
    end,
    
    inspectItemEquipped = function(self)
        draw:initScreen(38, "image/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        draw:item(self.item)
        
        draw:newline()
        draw:options({"Unequip"})
        
        if self.key == "u" then
            player:unequip(self.item)
            self:up()
        elseif self.key == "escape" then self:up() end
    end,
    
    crafting = function(self)
        draw:initScreen(38, "image/crafting")
        
        draw:text("Please purchase the crafting DLC for $99.99!")
        
        draw:newline()
        draw:text("- Press ESC to go back.")
        
        if self.key == "escape" then self:up() end
    end,
}