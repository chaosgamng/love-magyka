require "script/color"
require "script/image"
require "script/tools"

draw = {
    width = 10,
    height = 20,
    row = 3,
    
    
    -- Base
    
    
    text = function(self, text, ...)
        local arg = {...}
        x = 4
        c = color.white
        
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
        
        text = tostring(text)
        love.graphics.setColor(c)
        love.graphics.print(text, (x - 1)*self.width, (self.row - 1)*self.height)
        self.row = self.row + 1
    end,
    
    icon = function(self, image, x, ...)
        local arg = {...}
        c = color.white
        
        if #arg == 1 then
            if type(arg[1]) == "number" then self.row = arg[1]
            elseif type(arg[1]) == "table" then c = arg[1] end
        elseif #arg == 2 then
            if type(arg[2]) == "number" then self.row = arg[2]
            elseif type(arg[2]) == "table" then c = arg[2] end
        end
        
        love.graphics.setColor(color.white)
        love.graphics.draw(image, (x - 1)*self.width, (self.row - 1)*self.height)
    end,
    
    rect = function(self, c, x, y, w, h)
        w = w or 1
        h = h or 1
        
        love.graphics.setColor(c)
        love.graphics.rectangle("fill", (x-1)*self.width, (y-1)*self.height, w*self.width, h*self.height)
    end,
    
    icon = function(self, i, x, y, c, s)
        c = c or color.white
        s = s or 1
        if image[i] then i = image[i] else i = image["icon/default"] end
        love.graphics.setColor(c)
        love.graphics.draw(i, (x-1)*self.width, (y-1)*self.height, 0, s)
    end,
    
    image = function(self, i, x, y)
        if not image[i] then i = "image/default" end
        self:icon(i, x, y, color.white, 8)
    end,
    
    newline = function(self)
        self.row = self.row + 1
    end,
    
    top = function(self)
        self.row = 3
    end,
    
    
    -- Compound
    
    
    initScreen = function(self, subLeft, i)
        self:top()
        subLeft = self:border(subLeft)
        self:image(i, subLeft, 2, color.white)
    end,
    
    hpmp = function(self, entity, x, y)
        x = x or 4
        if y then self.row = y end
        
        self:text("%s [Lvl 1 Warrior]" % {entity:get("name")}, x)
        self:icon(hp, x, self.row, color.hp)
        self:bar(entity:get("hp"), entity:get("max_hp"), color.hp, color.gray48, 40, "HP: ", "#", x + 2)
        self:icon(mp, x, self.row, color.mp)
        self:bar(entity:get("mp"), entity:get("max_mp"), color.mp, color.gray48, 40, "MP: ", "#", x + 2)
    end,
    
    mainStats = function(self, entity, x, y)
        x = x or 4
        if y then self.row = y end
        
        self:hpmp(entity, x)
        self:icon(xp, x, self.row, color.xp)
        self:bar(entity:get("xp"), entity:get("max_xp"), color.xp, color.gray48, 40, "XP: ", "#", x + 2)
        self:icon(gp, x, self.row, color.gp)
        self:text("Gold: %d" % {entity:get("gp")}, x + 2)
    end,
    
    options = function(self, options, x, y)
        x = x or 4
        if y then self.row = y end
        
        length = #options
        self:rect(color.gray28, x, self.row, 3, length * 2 - 1)
        
        for k, v in pairs(options) do
            self:text('[%s] {%s}' % {v:sub(1, 1), v}, x)
            if k < length then self:text("|", x + 1, self.row) end
        end
    end,
    
    bar = function(self, current, maximum, fillColor, emptyColor, width, label, form, x, y)
        x = x or 4
        if y then self.row = y end
        
        if current == 0 or current == maximum then
            if current == 0 then c = emptyColor else c = fillColor end
            
            self:icon("icon/bar_left", x, self.row, c)
            for i = 1, width - 1 do self:icon("icon/bar_middle", x + i, self.row, c) end
            self:icon("icon/bar_right", x + width - 1, self.row, c)
        else
            fillLength = math.ceil((current / maximum) * width)
            if fillLength > width then fillLength = width end
            if fillLength < 1 then fillLength = 1 end
            
            self:icon("icon/bar_left", x, y, fillColor)
            for i = 1, fillLength do self:icon("icon/bar_middle", x + i, self.row, fillColor) end
            for i = fillLength, width - 1 do self:icon("icon/bar_middle", x + i, self.row, emptyColor) end
            self:icon("icon/bar_right", x + width - 1, self.row, emptyColor)
        end
        
        if form == "%" or form == "percent" then
            label = label .. tostring(math.ceil(current / maximum * 100))
        elseif form == "#" or form == "number" then
            label = label .. "%d/%d" % {current, maximum}
        else
            label = ""
        end
        
        self:text(label, x + width + 1)
    end,
    
    border = function(self, subWidth)
        subWidth = subWidth or 1
        
        c = color.gray28
        
        self:rect(c, 1, 1, screen.width, 1)
        self:rect(c, 1, screen.height, screen.width, 1)
        self:rect(c, 1, 1, 2, screen.height)
        self:rect(c, screen.width - 1, 1, 2, screen.height)
        
        self:rect(c, screen.width - subWidth - 1, 1, 2, screen.height)
        return screen.width - subWidth + 1
    end,
}