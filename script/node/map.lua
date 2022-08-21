require "script/node/node"

Map = Node{
    classType = "map",
    name = "map",
    tiles = {},
    collision = {},
    data = {},
    background = {0, 0, 0},
    
    get = function(self, key, ...)
        local arg = {...}
        
        if key == "tiles" then
            local x = arg[1]
            local y = arg[2]
            
            if x >= #self.tiles[1] or x < 0 then return self.background end
            if y >= #self.tiles or y < 0 then return self.background end
            
            return self.tiles[y][x]
        elseif key == "collision" then
            local x = arg[1]
            local y = arg[2]
            
            if x >= #self.collision[1] or x < 0 then return false end
            if y >= #self.collision or y < 0 then return false end
            
            return self.collision[y][x]
        else
            return self[key]
        end
    end,
    
    loadData = function(self)
        local tileFile = "map/%s.png" % {self.name}
        local collisionFile = "map/%s Collision.png" % {self.name}
        local dataFile = "map/"..self.name
        
        local tileImage = love.image.newImageData(tileFile)
        local collisionImage = love.image.newImageData(collisionFile)
        self.data = require(dataFile)
        
        for y = 0, tileImage:getHeight() - 1 do
            local tileRow = {}
            local collisionRow = {}
            
            for x = 0, tileImage:getWidth() - 1 do
                local r, g, b, a = tileImage:getPixel(x, y)
                table.insert(tileRow, {r, g, b})
                
                r, g, b, a = collisionImage:getPixel(x, y)
                table.insert(collisionRow, r == 1)
            end
            
            table.insert(self.tiles, tileRow)
            table.insert(self.collision, collisionRow)
        end
        
        self.data.portalTiles = {}
        for k, v in ipairs(self.data.portals) do
            if v.town then
                portal = v
                self.data.portalTiles[v.y] = {}
                self.data.portalTiles[v.y+1] = {}
                self.data.portalTiles[v.y][v.x] = portal
                self.data.portalTiles[v.y][v.x+1] = portal
                self.data.portalTiles[v.y+1][v.x] = portal
                self.data.portalTiles[v.y+1][v.x+1] = portal
            end
        end
    end,
    
    draw = function(self, playerX, playerY, width, height, mapLeft, mapTop)
        if #self.tiles[1] < width then width = #self.tiles[0] end
        if #self.tiles < height then height = #self.tiles end
        
        local left = playerX - math.floor(width / 2) - 1
        local right = playerX + math.floor(width / 2)
        local top = playerY - math.floor(height / 2) - 1
        local bottom = playerY + math.floor(height / 2)
        
        local mapY = mapTop
        for y = top, bottom do
            local mapX = mapLeft
            for x = left, right do
                draw:rect(self:get("tiles", x, y), mapX, mapY, 2, 1)
                mapX = mapX + 2
            end
            mapY = mapY + 1
        end
    end,
}