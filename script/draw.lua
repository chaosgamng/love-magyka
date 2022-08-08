require "script/color"
require "script/image"
require "script/tools"

draw = {
    width = 10,
    height = 20,
    
    text = function(self, text, x, y, c)
        c = c or color.white
        text = tostring(text)
        love.graphics.setColor(c)
        love.graphics.print(text, (x-1)*self.width, (y-1)*self.height)
    end,
    
    icon = function(self, image, x, y, c)
        c = c or color.white
        love.graphics.setColor(color.white)
        love.graphics.draw(image, (x-1)*self.width, (y-1)*self.height)
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
        self:icon(i, x, y, color.white, 8)
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
    
    options = function(self, options, x, y)
        length = #options
        self:rect(color.gray28, x, y, 3, length * 2 - 1)
        
        for k, v in pairs(options) do
            self:text('[%s] {%s}' % {v:sub(1, 1), v}, x, y + (k - 1) * 2)
            if k < length then self:text("|", x + 1, y + k * 2 - 1) end
        end
    end,
    
    bar = function(self, current, maximum, fillColor, emptyColor, width, label, form, x, y)
        if current == 0 or current == maximum then
            if current == 0 then c = emptyColor else c = fillColor end
            
            self:icon("icon/bar_left", x, y, c)
            for i = 1, width - 1 do self:icon("icon/bar_middle", x + i, y, c) end
            self:icon("icon/bar_right", x + width - 1, y, c)
        else
            fillLength = math.ceil((current / maximum) * width)
            if fillLength > width then fillLength = width end
            if fillLength < 1 then fillLength = 1 end
            
            self:icon("icon/bar_left", x, y, fillColor)
            for i = 1, fillLength do self:icon("icon/bar_middle", x + i, y, fillColor) end
            for i = fillLength, width - 1 do self:icon("icon/bar_middle", x + i, y, emptyColor) end
            self:icon("icon/bar_right", x + width - 1, y, emptyColor)
        end
        
        if form == "%" or form == "percent" then
            label = label .. tostring(math.ceil(current / maximum * 100))
        elseif form == "#" or form == "number" then
            label = label .. "%d/%d" % {current, maximum}
        else
            label = ""
        end
        
        self:text(label, x + width + 1, y)
    end,
}