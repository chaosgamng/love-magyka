require "script/color"
require "script/globals"
require "script/image"
require "script/tools"

draw = {
    width = 10,
    height = 20,
    row = 3,
    subLeft = 38,
    
    
    -- Base
    
    
    text = function(self, text, ...)
        local arg = {...}
        local x = 4
        local c = color.white
        
        if #arg == 1 then
            if type(arg[1]) == "number" then x = arg[1]
            elseif type(arg[1]) == "table" then c = arg[1] end
        elseif #arg == 2 then
            x = arg[1]
            if type(arg[2]) == "number" then self.row = arg[2]
            elseif type(arg[2]) == "table" then c = arg[2] end
        elseif #arg == 3 then
            x = arg[1]
            y = arg[2]
            c = arg[3]
        end
        
        local oText = text
        local parsedText = {}
        local parsedColors = {c}
        
        while true do
            oJ = 0
            i = string.find(text, "{", 1, true)
            j = string.find(text, "}", 1, true)
            
            if i then
                if i > 1 then table.insert(parsedText, string.sub(text, oJ + 1, i - 1))
                else table.insert(parsedText, "") end
                
                table.insert(parsedColors, color[string.sub(text, i + 1, j - 1)])
                text = string.sub(text, j + 1)
            else
                table.insert(parsedText, string.sub(text, oJ + 1))
                break
            end
        end
        
        if #parsedText ~= #parsedColors then
            parsedText = {oText}
            parsedColors = {c}
        end
        
        local i = 0
        for k, v in ipairs(parsedText) do
            love.graphics.setColor(parsedColors[k])
            love.graphics.print(v, (x + i - 1)*self.width, (self.row - 1)*self.height)
            i = i + string.len(v)
        end
        
        local newlines = select(2, string.match(text, "\n", 1, true)) or 0
        self.row = self.row + 1 + newlines
    end,
    
    icon = function(self, i, ...)
        local arg = {...}
        local x = 4
        local c = color.white
        local s = 1
        
        if #arg == 1 then
            if type(arg[1]) == "number" then x = arg[1]
            elseif type(arg[1]) == "table" then c = arg[1] end
        elseif #arg == 2 then
            x = arg[1]
            if type(arg[2]) == "number" then self.row = arg[2]
            elseif type(arg[2]) == "table" then c = arg[2] end
        elseif #arg == 3 then
            x = arg[1]
            self.row = arg[2]
            if type(arg[3]) == "number" then s = arg[3]
            elseif type(arg[3]) == "table" then c = arg[3] end
        elseif #arg == 4 then
            x = arg[1]
            y = arg[2]
            c = arg[3]
            s = arg[4]
        end
        
        if type(i) == "string" and image[i] then i = image[i] else i = image["icon/default"] end
        love.graphics.setColor(c)
        love.graphics.draw(i, (x - 1)*self.width, (self.row - 1)*self.height, 0, s)
    end,
    
    rect = function(self, c, x, y, w, h)
        local w = w or 1
        local h = h or 1
        
        love.graphics.setColor(c)
        love.graphics.rectangle("fill", (x-1)*self.width, (y-1)*self.height, w*self.width, h*self.height)
    end,
    
    image = function(self, i, x, y)
        local i = i or "image/default"
        if not image[i] then i = "image/default" end
        self:icon(i, x, y, 8)
    end,
    
    newline = function(self)
        self.row = self.row + 1
    end,
    
    top = function(self)
        self.row = 3
    end,
    
    
    -- Compound
    
    
    initScreen = function(self, subWidth, i)
        self:top()
        self:border(subWidth)
        self:image(i, self.subLeft, 2, color.white)
        self:top()
    end,
    
    hpmp = function(self, entity, x, y)
        local x = x or 4
        if y then self.row = y end
        
        self:text("%s [Lvl 1 Warrior]" % {entity:get("name")}, x)
        self:icon(hp, x, self.row, color.hp)
        self:bar(entity:get("hp"), entity:get("stats").maxHp, color.hp, color.gray48, 40, "HP: ", "#", x + 2)
        self:icon(mp, x, self.row, color.mp)
        self:bar(entity:get("mp"), entity:get("stats").maxMp, color.mp, color.gray48, 40, "MP: ", "#", x + 2)
    end,
    
    hpmpAlt = function(self, entity, x, y)
        self:text(entity:get("name"), x, y)
        self:icon(hp, x, self.row, color.hp)
        self:bar(entity:get("hp"), entity:get("stats").maxHp, color.hp, color.gray48, 20, "HP: ", "%", x + 2)
        self:icon(mp, x, self.row, color.mp)
        self:bar(entity:get("mp"), entity:get("stats").maxMp, color.mp, color.gray48, 20, "MP: ", "%", x + 2)
    end,
    
    mainStats = function(self, entity, x, y)
        local x = x or 4
        if y then self.row = y end
        
        self:hpmp(entity, x)
        self:icon(xp, x, self.row, color.xp)
        self:bar(entity:get("xp"), entity:get("maxXp"), color.xp, color.gray48, 40, "XP: ", "#", x + 2)
        self:icon(gp, x, self.row, color.gp)
        self:text("Gold: %d" % {entity:get("gp")}, x + 2)
    end,
    
    options = function(self, options, x, y)
        local x = x or 4
        if y then self.row = y end
        
        local length = #options
        self:rect(color.gray28, x, self.row, 3, length * 2 - 1)
        
        for k, v in pairs(options) do
            self:text("[%s] %s" % {v:sub(1, 1), v}, x)
            if k < length then self:text("|", x + 1, self.row) end
        end
    end,
    
    bar = function(self, current, maximum, fillColor, emptyColor, width, label, form, x, y)
        local x = x or 4
        if y then self.row = y end
        
        if current == 0 or current == maximum then
            if current == 0 then c = emptyColor else c = fillColor end
            
            self:icon("icon/bar_left", x, c)
            for i = 1, width - 1 do self:icon("icon/bar_middle", x + i, c) end
            self:icon("icon/bar_right", x + width - 1, c)
        else
            local fillLength = math.ceil((current / maximum) * width)
            if fillLength > width then fillLength = width end
            if fillLength < 1 then fillLength = 1 end
            
            self:icon("icon/bar_left", x, fillColor)
            for i = 1, fillLength do self:icon("icon/bar_middle", x + i, fillColor) end
            for i = fillLength, width - 1 do self:icon("icon/bar_middle", x + i, emptyColor) end
            self:icon("icon/bar_right", x + width - 1, emptyColor)
        end
        
        local labelText = ""
        if form == "%" or form == "percent" then
            labelText = label..tostring(math.ceil(current / maximum * 100)).."%"
        elseif form == "#" or form == "number" then
            labelText = label.."%d/%d" % {current, maximum}
        end
        
        self:text(labelText, x + width + 1)
    end,
    
    border = function(self, subWidth)
        local subWidth = subWidth or 1
        local c = color.gray28
        
        self:rect(c, 1, 1, screen.width, 1)
        self:rect(c, 1, screen.height, screen.width, 1)
        self:rect(c, 1, 1, 2, screen.height)
        self:rect(c, screen.width - 1, 1, 2, screen.height)
        
        self:rect(c, screen.width - subWidth - 1, 1, 2, screen.height)
        self.subLeft = screen.width - subWidth + 1
    end,
}