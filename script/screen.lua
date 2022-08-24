require "script/globals"
require "script/tools"
require "script/node/map"
require "script/node/town"

screen = {
    width = math.floor(love.graphics.getWidth() / 10),
    height = math.floor(love.graphics.getHeight() / 20),
    
    current = "title",
    post = "title",
    branch = {},
    branchData = {},
    branchDataDefaults = {
        map = {
            map = nil,
            portal = nil,
            hunting = false,
            steps = 0,
        },
        town = {
            town = nil,
            store = "",
            storeType = "",
        },
        store = {
            page = 1,
        },
        inventory = {
            page = 1,
        },
        inventorySell = {
        
        },
		battleItem = {
			page = 1,
		},
        battle = {
            turn = 1,
            turnOrder = {},
            stage = "prebattle",
            enemy = {},
            text = {},
            artChosen = false,
			itemChosen = false,
            targetType = "",
			target = "",
        },
        inspectItem = {
            stage = "input",
            quantity = 1,
            text = "",
        },
        inspectItemSell = {
            stage = "input",
            quantity = 1,
        },
        inspectItemStore = {
            stage = "input",
            quantity = 0,
        },
        inspectItemEquipped = {
            stage = "input",
            option = "",
            text = "",
        },
        crafting = {
            page = 1,
            station = "none",
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
            table.remove(self.branchData, i)
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
    
    get = function(self, key, screen)
		screen = screen or self.current
        return self.branchData[screen][key]
    end,
    
    set = function(self, key, value, screen)
		screen = screen or self.current
        self.branchData[screen][key] = value
    end,
    
    add = function(self, key, value)
        self.branchData[self.current][key] = self.branchData[self.current][key] + value
    end,
    
    pages = function(self, list, printFunction, confirmFunction, cancelFunction)
		local start = (self:get("page") - 1) * 10 + 1
		local stop = self:get("page") * 10
		if stop > #list then stop = #list end
		local left = self:get("page") > 1
		local right = self:get("page") * 10 + 1 < #list
		
		local option = nil
        
		if #list == 0 then
			draw:text("{gray68}- Empty")
		else
			for i = start, stop do
                local inputTextPadding = #tostring(stop) - #tostring(i)
                local inputTextPrefix = tostring(i):sub(1, #tostring(i) - 1)
                local inputText = tostring(i):sub(-1)
				
				local text = "%s(%d) " % {inputTextPrefix, inputText}
				text = text..printFunction(list[i])
				
				draw:text(text, 4 + inputTextPadding)
			end
		end
		
        draw:newline()
        draw:text("- Press a number or letter to select an option.")
        draw:text("  Press [LEFT] and [RIGHT] to navigate pages. Press [ESC] to go back.")
        
		if self.key == "0" then self.key = "10"
        elseif self.key == "left" and left then self:add("page", -1)
        elseif self.key == "right" and right then self:add("page", 1) end
		
		if isInRange(self.key, 1, #list - start + 1) then confirmFunction(list[tonumber(self.key) + start - 1])
        else cancelFunction() end
	end,
	
	quantity = function(self, maximum, confirmFunction, cancelFunction)
        draw:newline()
        draw:text("- Press [LEFT] to select minimum. Press [RIGHT] to select maximum.")
        draw:text("  Press [UP] and [DOWN] to change quantity. Press [ENTER] to confirm.")
        
        draw:newline()
        draw:text("Currently seleced: {gp}%d{white} (Max: %d)." % {self:get("quantity"), maximum})
        
        if self.key == "left" and maximum ~= 0 then self:set("quantity", 1)
        elseif self.key == "right" and maximum ~= 0 then self:set("quantity", maximum)
        elseif self.key == "up" and self:get("quantity") < maximum then self:add("quantity", 1)
        elseif self.key == "down" and self:get("quantity") > 1 then self:add("quantity", -1)
        elseif self.key == "return" and maximum ~= 0 then confirmFunction()
        elseif self.key == "escape" then cancelFunction() end
    end,
    
    
    -- SCREENS --
    
    
    title = function(self)
        draw:border(0)
        draw:top()
        
        local magyka = {
            "  .x8888x.:d8888:.:d888b                                        ,688889,                    ",
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
        if self:get("map") == nil then
            self:set("map", newMap(world:get("currentMap")))
        end
        
        -- Drawing
        draw:initScreen((screen.height - 1) * 2)
        local map = self:get("map")
        
        local left = draw.subLeft
		local width = math.floor((self.width - 2 - left) / 2)
		local top = 2
		local height = self.height - 1 - top
        
        local x = world:get("playerX")
        local y = world:get("playerY")
        
        map:draw(x, y, width, height, left, top)
        draw:rect("black", left + width + 1, top + math.floor(height / 2) + 1, 2, 1)
        
        draw:top()
        if self:get("hunting") then draw:text("Hunting: {green}True")
        else draw:text("Hunting: {red}False") end
        
        draw:newline()
        draw:options({"Camp", "Hunt"})
        
        draw:newline()
        draw:text("- Press a letter to select an option.")
        
        -- Input
        local left = input.left[2]
        local right = input.right[2]
        local up = input.up[2]
        local down = input.down[2]
        
        local moveX = 0
        local moveY = 0
        
        if self.key == "c" then self:down("camp") end
        if self.key == "h" then self:set("hunting", not self:get("hunting")) end
        if left  and map:get("collision", x - 1, y) then moveX = moveX - 1 end
        if right and map:get("collision", x + 1, y) then moveX = moveX + 1 end
        if up    and map:get("collision", x, y - 1) then moveY = moveY - 1 end
        if down  and map:get("collision", x, y + 1) then moveY = moveY + 1 end
        
        input.left[2] = false
        input.right[2] = false
        input.up[2] = false
        input.down[2] = false
        
        -- Updating
        if moveX ~= 0 or moveY ~= 0 then
            world:add("playerX", moveX)
            world:add("playerY", moveY)
            
            local x = world:get("playerX")
            local y = world:get("playerY")
            local group = map:get("group", x, y)
            
            if map.data.portalTiles[y] then
                if map.data.portalTiles[y][x] then
                    local portal = map.data.portalTiles[y][x]
                    if portal.town then
                        world:set("playerX", portal.x + 1)
                        world:set("playerY", portal.y + 2)
                        self:set("portal", portal)
                        self:down("town")
                    end
                end
            end
            
            if group > 0 then
                local move = math.abs(moveX) + math.abs(moveY)
                if self:get("hunting") then self:add("steps", move)
                elseif rand(1, 20) == move then self:add("steps", move) end
                
                if self:get("steps") >= 20 then
                    local enemies = map:encounter(group)
                    self:set("steps", 0)
                    
                    if #enemies > 0 then
                        self:down("battle")
                        self:set("enemy", enemies)
                    end
                end
            end
        end
    end,
    
    town = function(self)
        if self:get("town") == nil then
            self:set("town", newTown(self:get("portal", "map").name))
        end
        
        draw:initScreen(38, "screen/town")
        
        draw:mainStats(player)
        
        draw:newline()
        local storeNames = self:get("town").storeNames
        local storeTypes = self:get("town").storeTypes
        draw:optionsNumbered(storeNames)
        
        if isInRange(self.key, 1, #storeNames) then
            local storeType = storeTypes[tonumber(self.key)]
            self:set("store", self:get("town").stores[storeType])
            self:set("storeType", storeType)
            self:down("store")
        elseif self.key == "escape" then self:up() end
    end,
    
    store = function(self)
        local store = self:get("store", "town")
        
        draw:initScreen(38, "screen/"..self:get("storeType", "town"))
        
        if store.sell then
            draw:newline()
            draw:options({"Sell"})
        end
        
        local option, index = self:pages(
            store.items,
            function(item) return item:display().."  <gp> "..item:get("value") end
            function(item)
                self.item = item
                self:down("inspectItemStore")
            end,
            function() self:up() end
        )
        
        if self.key == "s" and store.sell then
            self:down("inventorySell")
    end,
    
    camp = function(self)
        draw:initScreen(38, "screen/camp")
        
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
        draw:initScreen(38, "screen/inventory")

		local option, index = self:pages(
            player:get("inventory"),
            function(item)
                if item[1]:get("stackable") then return item[1]:display(item[2])
                else return item[1]:display() end
            end,
            function(item)
                self.item = item
                self:down("inspectItem")
            end,
            function() self:up() end
        )
    end,
    
    inventorySell = function(self)
        draw:initScreen(38, "screen/inventory")

		local option, index = self:pages(player:get("inventory"), function(item) if item[1]:get("stackable") then return item[1]:display(item[2]) else return item[1]:display() end end)
        
        draw:newline()
        draw:text("- Press a number to select an option. Press ESC to go back.")
		
        if option then
            self.item = player:get("inventory")[index][1]
            self:down("inspectItemSell")
        elseif self.key == "left" and left then self:add("page", -1)
        elseif self.key == "right" and right then self:add("page", 1)
        elseif self.key == "escape" then self:up() end
    end,
    
    equipment = function(self)
        draw:initScreen(38, "screen/equipment")
        
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
        draw:border(0)
        draw:rect("gray28", 39, 1, 2, self.height)
        draw:icon("battle/default", 41, 2, 5)
        
        -- Set up enemy images and spacing
        local enemyImages = {}
        local totalWidth = 0
        
        for k, v in ipairs(self:get("enemy")) do
            enemyImages[k] = {image = image["enemy/"..v:get("name")]}
            enemy = enemyImages[k]
            enemy.width = math.ceil(enemy.image:getWidth() / 2)
            enemy.height = math.ceil(enemy.image:getHeight() / 4)
            totalWidth = totalWidth + enemy.width
        end
        
        local altWidth = self.width - 42
        local spaces = #self:get("enemy") - 1
        
        local spaceBetweenEnemies = 2
        if spaces == 0 then spaceBetweenEnemies = 0
        else spacebetweenEnemies = 16 - (spaces * 2) end
        
        totalWidth = totalWidth + spaceBetweenEnemies * spaces
        
        local offset = math.floor((altWidth - totalWidth) / 2) + 42
        
        -- Draw enemies and enemy info
        for k, v in ipairs(self:get("enemy")) do
            local enemy = enemyImages[k]
            enemy.x = offset
            enemy.y = 27 - enemy.height
            local enemyCenter = enemy.x + math.floor(enemy.width / 2)
            local indexText = "(%d)" % {k}
            local indexX = enemyCenter - 1
            local nameX = enemyCenter - math.floor(#v:get("name") / 2)
            local levelText = "[Lvl %d]" % {v:get("level")}
            local levelX = enemyCenter - math.floor(#levelText / 2)
            local barX = enemyCenter - 4
            
            if v:get("hp") > 0 then
                draw:icon(enemy.image, enemy.x, enemy.y, 5)
                
                draw:text(indexText, indexX, enemy.y - 6)
                draw:text(v:get("name"), nameX, enemy.y - 4)
                draw:text(levelText, levelX, enemy.y - 3)
                draw:bar(v:get("hp"), v:get("stats").maxHp, color.hp, color.gray48, 8, "", "", barX, 28)
                draw:bar(v:get("mp"), v:get("stats").maxMp, color.mp, color.gray48, 8, "", "", barX, 29)
            end
            
            offset = offset + enemy.width + spaceBetweenEnemies
        end
        
        draw:top()
        draw:hpmp(player, 16)
        draw:newline()
        
        -- Set up turn order
        if self:get("stage") == "prebattle" then
            self:set("stage", "input")
            table.insert(self:get("turnOrder"), "player")
            
            for k, v in ipairs(self:get("enemy")) do
                table.insert(self:get("turnOrder"), k)
            end
        
        -- Update turn order and check for victory/defeat
        elseif self:get("stage") == "update" then
            for i = #self:get("turnOrder"), 1, -1 do
                if type(self:get("turnOrder")[i]) == "number" then
                    local enemy = self:get("enemy")[self:get("turnOrder")[i]]
                    if enemy:get("hp") <= 0 then table.remove(self:get("turnOrder"), i) end
                end 
            end
            
            if #self:get("turnOrder") == 1 and self:get("turnOrder")[1] == "player" then
                self:down("victory")
            elseif player:get("hp") <= 0 then
                self:down("defeat")
            else
                self:add("turn", 1)
                if self:get("turn") > #self:get("turnOrder") then self:set("turn", 1) end
                
                self:set("stage", "input")
            end
        
        -- Output damage text
        elseif self:get("stage") == "output" then
            draw:top()
            for k, v in pairs(self:get("text")) do draw:text(v, 42) end
            draw:newline()
            draw:rect(color.gray28, 43, draw.row, 13, 1)
            draw:text("[PRESS ENTER]", 43)
            if self.key == "return" then self:set("stage", "update") end
        
        -- Player's Turn
        elseif self:get("turnOrder")[self:get("turn")] == "player" then
            -- Choose action
            if self:get("stage") == "input" then
                self:set("text", {})
                if self:get("itemChosen") then
                    self:set("targetType", "all")
                    self:set("stage", "target")
                end
                
                draw:options({"Fight", "Art", "Guard", "Item", "Escape"})
                
                if self.key == "f" then
                    self:set("targetType", "enemy")
                    self:set("stage", "target")
                elseif self.key == "i" then
                    self:down("battleItem")
                end
            
            -- Choose target
            elseif self:get("stage") == "target" then
                if self:get("targetType") ~= "enemy" then
                    draw:options({"Self"})
                    draw:newline()
                end
                
                local targets = {}
                local index = 1
                
                for k, v in ipairs(self:get("enemy")) do
                    if v:get("hp") > 0 then
                        draw:rect(color.gray28, 5, draw.row, 3, 1)
                        draw:text(" (%d) %s" % {index, v:get("name")})
                        index = index + 1
                        table.insert(targets, v)
                    end
                end
                
                local targetChosen = false
                
                if self.key == "s" and self:get("targetType") ~= "enemy" then
                    self:set("target", player)
                    targetChosen = true
                elseif isInRange(self.key, 1, index) then
                    local enemy = targets[tonumber(self.key)]
                    if enemy:get("hp") > 0 then
                        self:set("target", enemy)
                        targetChosen = true
                    end
                elseif self.key == "escape" then self:set("stage", "input") end
                
                if targetChosen then
                    if self:get("itemChosen") then
                        appendTable(self:get("text"), self.item:use(player, self:get("target")))
                        self:set("itemChosen", false)
                    elseif self:get("artChosen") then
                        -- do stuff lmao
                        self:set("artChosen", false)
                    else
                        appendTable(self:get("text"), player:attack(self:get("target")))
                    end
                    
                    self:set("stage", "output")
                end
            end
        
        -- Enemy's Turn
        elseif type(self:get("turnOrder")[self:get("turn")]) == "number" then
            local enemy = self:get("enemy")[self:get("turnOrder")[self:get("turn")]]
            
            if self:get("stage") == "input" then
                self:set("text", {})
                appendTable(self:get("text"), enemy:attack(player))
                self:set("stage", "output")
            end
        end
    end,
    
    battleArt = function(self)
    
    end,
    
    battleItem = function(self)
		draw:initScreen(38, "screen/inventory")
		
		inventory = player:get("inventory")
		itemList = {}
		
		for k, v in ipairs(inventory) do
			if v[1]:get("consumable") then table.insert(itemList, v) end
		end
		
		local option, index = self:pages(itemList, function(item) if item[1]:get("stackable") then return item[1]:display(item[2]) else return item[1]:display() end end)
		
		if option then
			self.item = itemList[index][1]
			self:down("inspectItemBattle")
		elseif self.key == "escape" then self:up() end
    end,
    
    victory = function(self)
        draw:initScreen(38, "screen/victory")
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You won! Good job.")
        
        if self.key == "return" then self:upPast("battle") end
    end,
    
    defeat = function(self)
        draw:initScreen(38, "screen/defeat")
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You lost! Fuck you.")
        
        if self.key == "return" then self:upPast("battle") end
    end,
    
    inspectItem = function(self)
        draw:initScreen(38, "screen/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        local quantity = 0
        if self.item:get("stackable") then quantity = player:numOfItem(self.item) end
        draw:item(self.item, quantity)
        
        if self:get("stage") == "input" then
            draw:newline()
            if self.item:get("consumable") then draw:options({"Use", "Discard"})
            elseif self.item:get("equipment") then draw:options({"Equip", "Discard"})
            else draw:options({"Discard"}) end
            
            draw:newline()
            draw:text("- Press a key to select an option.")
            
            if self.key == "e" and self.item:get("equipment") then
                player:equip(self.item)
                self:set("stage", "equip")
            elseif self.key == "u" and self.item:get("consumable") then
                self:set("text", self.item:use(player))
                if not self.item:get("infinite") then player:removeItem(self.item) end
                self:set("stage", "use")
            elseif self.key == "d" then
                if self.item:get("stackable") then
                    self:set("stage", "discard")
                else
                    player:removeItem(self.item)
                    self:set("quantity", 0)
                    self:set("stage", "discard output")
                end
            elseif self.key == "escape" then self:up() end
        
        
        elseif self:get("stage") == "equip" then
            draw:newline()
            draw:text("Equipped "..self.item:display()..".")
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then self:up() end
        
        
        elseif self:get("stage") == "use" then
            draw:newline()
            for k, v in ipairs(self:get("text")) do draw:text(v) end
            
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then self:set("stage", "output") end
        
        
        elseif self:get("stage") == "discard" then
            self:quantity(player:numOfItem(self.item), function() self:set("stage", "discard output") end, function() self:set("stage", "input") end)
        
        
        elseif self:get("stage") == "discard output" then
            local discardText = ""
            if quantity == 1 and not self.item:get("stackable") then discardText = self.item:display()
            else discardText = self.item:display(self:get("quantity")) end
            
            draw:newline()
            draw:text("Discarded %s." % {discardText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then self:set("stage", "output") end
        
        
        elseif self:get("stage") == "output" then
            player:removeItem(self.item, self:get("quantity"))
            
            if player:numOfItem(self.item) == 0 or not self.item:get("stackable") then self:up()
            else self:set("stage", "input") end
        end
    end,
    
    inspectItemSell = function(self)
        draw:initScreen(38, "screen/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        local quantity = 0
        if self.item:get("stackable") then quantity = player:numOfItem(self.item) end
        draw:item(self.item, quantity)
        
        if self:get("stage") == "input" then
            draw:newline()
            draw:options({"Sell"})
            draw:newline()
            draw:text("- Press a key to select an option. Press [ESC] to go back.")
            
            if self.key == "s" then
                if self.item:get("stackable") then
                    self:set("stage", "sell")
                else
                    player:removeItem(self.item)
                    self:set("quantity", 0)
                    self:set("stage", "sell output")
                end
            elseif self.key == "escape" then self:up() end
        
        
        elseif self:get("stage") == "sell" then
            self:quantity(player:numOfItem(self.item), function() self:set("stage", "sell output") end, function() self:set("stage", "input") end)
        
        
        elseif self:get("stage") == "sell output" then
            local sellText = ""
            if quantity == 1 and not self.item:get("stackable") then sellText = self.item:display()
            else sellText = self.item:display(self:get("quantity")) end
            
            local sellValue = math.ceil(self.item:get("value") * quantity * 0.67)
            sellText = sellText.." for <gp>{gp}%d{white}." % {sellValue}
            
            draw:newline()
            draw:text("Sold %s." % {sellText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then
                player:removeItem(self.item, self:get("quantity"))
                player:add("gp", sellValue)
                
                if player:numOfItem(self.item) == 0 or not self.item:get("stackable") then self:up()
                else self:set("stage", "input") end
            end
        end
    end,
    
    inspectItemStore = function(self)
        draw:initScreen(38, "screen/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        draw:item(self.item)
        
        if self:get("stage") == "input" then
            local maxBuy = math.floor(player:get("gp") / self.item:get("value"))
            self:quantity(maxBuy, function() self:set("stage", "output") end, function() self:up() end)
        
        
        elseif self:get("stage") == "output" then
            local buyText = ""
            if quantity == 1 and not self.item:get("stackable") then buyText = self.item:display()
            else buyText = self.item:display(self:get("quantity")) end
            
            draw:newline()
            draw:text("Bought %s." % {buyText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then
                player:addItem(newItem(self.item), self:get("quantity"))
                player:add("gp", -self:get("quantity") * self.item:get("value"))
                self:up()
            end
        end
    end,
    
    inspectItemEquipped = function(self)
        draw:initScreen(38, "screen/inspectItem")
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
    
	inspectItemBattle = function(self)
		draw:initScreen(38, "screen/inspectItem")
        draw:imageSide("item/"..self.item:get("name"), "item/default")
        
        draw:top()
        draw:item(self.item)
		
        draw:newline()
        draw:options({"Use"})
        
        if self.key == "u" and self.item:get("consumable") then
            self:set("itemChosen", true, "battle")
            self:upPast("battleItem")
        elseif self.key == "escape" then
            self:set("itemChosen", false, "battle")
            self:up()
        end
	end,
	
    crafting = function(self)
        draw:initScreen(38, "screen/crafting")
        
        local option, index = self:pages(
            player:get("recipes"),
            function(recipe)
                item = recipe:get("item")
                if item:get("stackable") then return item:display(recipe:get("quantity"))
                else return item:display() end
            end,
            function(recipe)
                self:down("craftItem")
                self:set("recipe", recipe, "craftItem")
            end,
            function() self:up() end
        )
    end,
    
    craftItem = function(self)
        
    end,
}