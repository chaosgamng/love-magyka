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
            page = 1,
        },
        arts = {
            page = 1,
        },
		battleItem = {
			page = 1,
            item = nil,
		},
        battleArt = {
            page = 1,
            art = nil
        },
        battle = {
            turn = 1,
            turnOrder = {},
            stage = "prebattle",
            enemy = {},
            text = {},
            art = nil,
            artChosen = false,
            item = nil,
			itemChosen = false,
            targetType = "",
			target = "",
        },
        victory = {
            stage = "input",
            lootEntity = newEntity{},
        },
        inspectItem = {
            stage = "input",
            quantity = 1,
            item = nil,
            text = {},
        },
        inspectItemBattle = {
            item = nil,
        },
        inspectItemSell = {
            stage = "input",
            quantity = 1,
            item = nil,
        },
        inspectItemStore = {
            stage = "input",
            quantity = 0,
            item = nil,
        },
        inspectItemEquipped = {
            stage = "input",
            item = nil,
            text = "",
        },
        inspectArt = {
            stage = "input",
            art = nil,
            text = {},
        },
        inspectArtBattle = {
            art = nil,
        },
        crafting = {
            page = 1,
            station = "none",
        },
        craftItem = {
            stage = "input",
            recipe = nil,
            quantity = 0,
        },
    },
    
    key = "",
    
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
        elseif self.key == "right" and right then self:add("page", 1)
        elseif self.key == "escape" then cancelFunction() end
		
		if isInRange(self.key, 1, #list - start + 1) then
            confirmFunction(list[tonumber(self.key) + start - 1])
        end
	end,
	
	quantity = function(self, maximum, confirmFunction, cancelFunction)
        draw:newline()
        draw:text("Currently seleced: {xp}%d{white} (Max: %d)." % {self:get("quantity"), maximum})
        
        draw:newline()
        draw:text("- Press [LEFT] to select minimum. Press [RIGHT] to select maximum.")
        draw:text("  Press [UP] and [DOWN] to change quantity. Press [ENTER] to confirm.")
        
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
        draw:mainStats(player, 20)
        
        draw:newline()
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
        if left  then moveX = moveX - 1 end
        if right then moveX = moveX + 1 end
        if up    then moveY = moveY - 1 end
        if down  then moveY = moveY + 1 end
        
        input.left[2] = false
        input.right[2] = false
        input.up[2] = false
        input.down[2] = false
        
        if not map:get("collision", x + moveX, y) then moveX = 0 end
        if not map:get("collision", x, y + moveY) then moveY = 0 end
        if not map:get("collision", x + moveX, y + moveY) then
            moveX = 0
            moveY = 0
        end
        
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
        
        self:pages(
            store.items,
            function(item) return item:display().."  <gp> "..item:get("value") end,
            function(item)
                self:down("inspectItemStore")
                self:set("item", item, "inspectItemStore")
            end,
            function() self:up() end
        )
        
        if self.key == "s" and store.sell then self:down("inventorySell") end
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
        elseif self.key == "a" then self:down("arts")
        elseif self.key == "c" then self:down("crafting")
        elseif self.key == "escape" then self:up() end
    end,
    
    inventory = function(self)
        draw:initScreen(38, "screen/inventory")

		self:pages(
            player:get("inventory"),
            function(item)
                if item[1]:get("stackable") then return item[1]:display(item[2])
                else return item[1]:display() end
            end,
            function(item)
                self:down("inspectItem")
                self:set("item", item[1], "inspectItem")
            end,
            function() self:up() end
        )
    end,
    
    inventorySell = function(self)
        draw:initScreen(38, "screen/inventory")

		self:pages(
            player:get("inventory"),
            function(item) 
                if item[1]:get("stackable") then return item[1]:display(item[2])
                else return item[1]:display() end
            end,
            function(item)
                self:down("inspectItemSell")
                self:set("item", item, "inspectItemSel")
            end,
            function() self:up() end
        )
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
                self:down("inspectItemEquipped")
                self:set("item", item, "inspectItemEquipped")
            end
        elseif self.key == "escape" then self:up() end
    end,
    
    arts = function(self)
        draw:initScreen(38, "screen/arts")
        
        self:pages(
            player:get("arts"),
            function(art)
                return art:display()
            end,
            function(art)
                self:down("inspectArt")
                self:set("art", art, "inspectArt")
            end,
            function() self:up() end
        )
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
                elseif self:get("artChosen") then
                    self:set("targetType", "all")
                    self:set("stage", "target")
                end
                
                draw:options({"Fight", "Art", "Guard", "Item", "Escape"})
                
                if self.key == "f" then
                    self:set("targetType", "enemy")
                    self:set("stage", "target")
                elseif self.key == "a" then
                    self:down("battleArt")
                elseif self.key == "i" then
                    self:down("battleItem")
                end
            
            -- Choose target
            elseif self:get("stage") == "target" then
                local autoSelect = self:get("targetType") == "enemy" and #self:get("enemy") == 1
                
                if self:get("targetType") ~= "enemy" then
                    draw:options({"Self"})
                    draw:newline()
                end
                
                local targets = {}
                local index = 1
                
                for k, v in ipairs(self:get("enemy")) do
                    if v:get("hp") > 0 then
                        if not autoSelect then
                            draw:rect(color.gray28, 5, draw.row, 3, 1)
                            draw:text(" (%d) %s" % {index, v:get("name")})
                        end
                        index = index + 1
                        table.insert(targets, v)
                    end
                end
                
                local targetChosen = false
                
                if self.key == "s" and self:get("targetType") ~= "enemy" then
                    self:set("target", player)
                    targetChosen = true
                elseif isInRange(self.key, 1, index) or autoSelect then
                    local index = tonumber(self.key)
                    if autoSelect then index = 1 end
                    
                    local enemy = targets[index]
                    if enemy:get("hp") > 0 then
                        self:set("target", enemy)
                        targetChosen = true
                    end
                elseif self.key == "escape" then self:set("stage", "input") end
                
                if targetChosen then
                    if self:get("itemChosen") then
                        for k, v in ipairs(self:get("item"):get("effect")) do
                            appendTable(self:get("text"), v:use(self:get("item"), player, self:get("target")))
                        end
                        self:set("itemChosen", false)
                    elseif self:get("artChosen") then
                        for k, v in ipairs(self:get("art"):get("effect")) do
                            appendTable(self:get("text"), v:use(self:get("art"), player, self:get("target")))
                        end
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
        draw:initScreen(38, "screen/arts")
        
        self:pages(
            player:get("arts"),
            function(art)
                return art:display()
            end,
            function(art)
                self:down("inspectArtBattle")
                self:set("art", art, "inspectArtBattle")
            end,
            function() self:up() end
        )
    end,
    
    battleItem = function(self)
		draw:initScreen(38, "screen/inventory")
		
		inventory = player:get("inventory")
		itemList = {}
		
		for k, v in ipairs(inventory) do
			if v[1]:get("consumable") then table.insert(itemList, v) end
		end
		
		self:pages(
            itemList,
            function(item)
                if item[1]:get("stackable") then return item[1]:display(item[2])
                else return item[1]:display() end
            end,
            function(item)
                self:down("inspectItemBattle")
                self:set("item", item, "inspectItemBattle")
            end,
            function() self:up() end
        )
    end,
    
    victory = function(self)
        print("here")
        draw:initScreen(38, "screen/victory")
        
        draw:top()
        draw:hpmp(player)
        
        draw:newline()
        draw:text("You won! Good job.")
        
        local lootEntity = self:get("lootEntity")
        
        if self:get("stage") == "input" then
            for k, v in ipairs(self:get("enemy", "battle")) do
                for _, loot in ipairs(v:get("inventory")) do
                    lootEntity.gp = lootEntity.gp + rand(loot.gp)
                    lootEntity.xp = lootEntity.xp + rand(loot.xp)
                    
                    for __, item in ipairs(loot:drop()) do
                        lootEntity:addItem(item[1], item[2])
                    end
                end
            end
            
            if lootEntity.gp then player:add("gp", lootEntity.gp) end
            if lootEntity.xp then player:add("xp", lootEntity.xp) end
            for k, v in ipairs(lootEntity:get("inventory")) do
                player:addItem(v[1], v[2])
            end
            self:set("stage", "output")
        
        
        elseif self:get("stage") == "output" then
            draw:newline()
            draw:text("Obtained:")
            draw:text(" GP: <gp> "..lootEntity.gp)
            draw:text(" XP: <xp> "..lootEntity.xp)
            
            if #lootEntity:get("inventory") > 0 then
                draw:newline()
                draw:text(" Items:")
                for k, v in ipairs(lootEntity:get("inventory")) do
                    local item = ""
                    if v[1]:get("stackable") then item = v[1]:display(v[2])
                    else item = v[1]:display() end
                    
                    draw:text(" - "..item)
                end
            end
            
            if self.key == "return" then self:upPast("battle") end
        end
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
        local item = self:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:top()
        local quantity = 0
        if item:get("stackable") then quantity = player:numOfItem(item) end
        draw:item(item, quantity)
        
        if self:get("stage") == "input" then
            draw:newline()
            if item:get("consumable") then draw:options({"Use", "Discard"})
            elseif item:get("equipment") then draw:options({"Equip", "Discard"})
            else draw:options({"Discard"}) end
            
            draw:newline()
            draw:text("- Press a key to select an option.")
            
            if self.key == "e" and item:get("equipment") then
                player:equip(item)
                self:set("stage", "equip")
            elseif self.key == "u" and item:get("consumable") then
                for k, v in ipairs(item:get("effect")) do
                    self:set("text", v:use(item, player))
                end
                if not item:get("infinite") then player:removeItem(item) end
                
                self:set("stage", "use")
            elseif self.key == "d" then
                if item:get("stackable") then
                    self:set("stage", "discard")
                else
                    player:removeItem(item)
                    self:set("quantity", 0)
                    
                    self:set("stage", "discard output")
                end
            elseif self.key == "escape" then self:up() end
        
        
        elseif self:get("stage") == "equip" then
            draw:newline()
            draw:text("Equipped "..item:display()..".")
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
            self:quantity(player:numOfItem(item), function() self:set("stage", "discard output") end, function() self:set("stage", "input") end)
        
        
        elseif self:get("stage") == "discard output" then
            local discardText = ""
            if quantity == 1 and not item:get("stackable") then discardText = item:display()
            else discardText = item:display(self:get("quantity")) end
            
            draw:newline()
            draw:text("Discarded %s." % {discardText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then
                player:removeItem(item, self:get("quantity"))
                self:set("stage", "output")
            end
        
        
        elseif self:get("stage") == "output" then
            if player:numOfItem(item) == 0 or not item:get("stackable") then self:up()
            else self:set("stage", "input") end
        end
    end,
    
    inspectItemSell = function(self)
        draw:initScreen(38, "screen/inspectItem")
        local item = self:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:top()
        local quantity = 0
        if item:get("stackable") then quantity = player:numOfItem(item) end
        draw:item(item, quantity)
        
        if self:get("stage") == "input" then
            draw:newline()
            draw:options({"Sell"})
            draw:newline()
            draw:text("- Press a key to select an option. Press [ESC] to go back.")
            
            if self.key == "s" then
                if item:get("stackable") then
                    self:set("stage", "sell")
                else
                    player:removeItem(item)
                    self:set("quantity", 0)
                    self:set("stage", "sell output")
                end
            elseif self.key == "escape" then self:up() end
        
        
        elseif self:get("stage") == "sell" then
            self:quantity(player:numOfItem(item), function() self:set("stage", "sell output") end, function() self:set("stage", "input") end)
        
        
        elseif self:get("stage") == "sell output" then
            local sellText = ""
            if quantity == 1 and not item:get("stackable") then sellText = item:display()
            else sellText = item:display(self:get("quantity")) end
            
            local sellValue = math.ceil(item:get("value") * quantity * 0.67)
            sellText = sellText.." for <gp>{gp}%d{white}." % {sellValue}
            
            draw:newline()
            draw:text("Sold %s." % {sellText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then
                player:removeItem(item, self:get("quantity"))
                player:add("gp", sellValue)
                
                if player:numOfItem(item) == 0 or not item:get("stackable") then self:up()
                else self:set("stage", "input") end
            end
        end
    end,
    
    inspectItemStore = function(self)
        draw:initScreen(38, "screen/inspectItem")
        local item = self:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:top()
        draw:item(item)
        
        if self:get("stage") == "input" then
            local maxBuy = math.floor(player:get("gp") / item:get("value"))
            self:quantity(maxBuy, function() self:set("stage", "output") end, function() self:up() end)
        
        
        elseif self:get("stage") == "output" then
            local buyText = ""
            if quantity == 1 and not item:get("stackable") then buyText = item:display()
            else buyText = item:display(self:get("quantity")) end
            
            draw:newline()
            draw:text("Bought %s." % {buyText})
            draw:newline()
            draw:text("- Press [ENTER] to continue.")
            
            if self.key == "escape" or self.key == "return" then
                player:addItem(newItem(item), self:get("quantity"))
                player:add("gp", -self:get("quantity") * item:get("value"))
                self:up()
            end
        end
    end,
    
    inspectItemEquipped = function(self)
        draw:initScreen(38, "screen/inspectItem")
        local item = self:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:top()
        draw:item(item)
        
        draw:newline()
        draw:options({"Unequip"})
        
        if self.key == "u" then
            player:unequip(item)
            self:up()
        elseif self.key == "escape" then self:up() end
    end,
    
	inspectItemBattle = function(self)
		draw:initScreen(38, "screen/inspectItem")
        local item = self:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:top()
        draw:item(item)
		
        draw:newline()
        draw:options({"Use"})
        
        if self.key == "u" and item:get("consumable") then
            self:set("itemChosen", true, "battle")
            self:set("item", item, "battle")
            self:upPast("battleItem")
        elseif self.key == "escape" then
            self:set("itemChosen", false, "battle")
            self:up()
        end
	end,
	
    inspectArt = function(self)
        draw:initScreen(38, "screen/inspectArt")
        local art = self:get("art")
        draw:imageSide("art/"..art:get("name"), "art/default")
        
        draw:top()
        draw:item(art)
        
        if self:get("stage") == "input" then
            if self.key == "escape" then self:up() end
        end
    end,
    
    inspectArtBattle = function(self)
        draw:initScreen(38, "screen/inspectArt")
        local art = self:get("art")
        draw:imageSide("art/"..art:get("name"), "art/default")
        
        draw:top()
        draw:item(art)
        
        draw:newline()
        draw:options({"Use"})
        
        if self.key == "u" then
            self:set("artChosen", true, "battle")
            self:set("art", art, "battle")
            self:upPast("battleArt")
        elseif self.key == "escape" then
            self:set("artChosen", false, "battle")
            self:up()
        end
    end,
    
    crafting = function(self)
        draw:initScreen(38, "screen/craftItem")
        
        self:pages(
            player:get("recipes"),
            function(recipe)
                local item = recipe:get("item")
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
        draw:initScreen(38, "screen/craftItem")
        local recipe = self:get("recipe")
        local item = recipe:get("item")
        draw:imageSide("item/"..item:get("name"), "item/default")
        
        draw:item(item)
        
        local craftable = true
        local numCraftable = 99999999
        for k, v in pairs(recipe:get("ingredients")) do
            local owned = player:numOfItem(k)
            
            if owned < v then
                craftable = false
                numCraftable = 0
            elseif math.floor(owned / v) < numCraftable then
                numCraftable = math.floor(owned / v)
            end
            
            draw:text("%dx %s (%d/%d)" % {v, newItem(k):display(), owned, v})
        end
        
        if item:get("equipment") and craftable then numCraftable = 1 end
        
        if self:get("stage") == "input" then
            self:quantity(
                numCraftable,
                function() self:set("stage", "output") end,
                function() up() end
            )
        
        
        elseif self:get("stage") == "output" then
            draw:newline()
            draw:text("Crafted %s." % item:display())
            
            if self.key == "escape" or self.key == "return" then
                for k, v in pairs(recipe:get("ingredients")) do
                    player:removeItem(k, v * self:get("quantity"))
                end
                player:addItem(newItem(item), self:get("quantity"))
                
                self:up()
            end
        end
    end,
}