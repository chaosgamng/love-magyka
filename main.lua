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
    
    update = function(self, dt)
        self[self.current](self)
    end,
    
    
    -- COMMON FUNCTIONS --
    
    
    init = function(subLeft, i)
        subLeft = draw:border(subLeft)
        draw:image(i, subLeft, 2, color.white)
    end,
    
    hpmp = function(x, y, entity)
        draw:icon(hp, x, y, color.hp)
        draw:bar(entity:get("hp"), entity:get("max_hp"), color.hp, color.gray48, 40, "HP: ", "#", 6, 4)
        draw:icon(mp, x, y + 1, color.mp)
        draw:bar(entity:get("mp"), entity:get("max_mp"), color.mp, color.gray48, 40, "MP: ", "#", 6, 5)
    end,
    
    hpmpxpgp = function(x, y, entity)
        draw:icon(hp, x, y, color.hp)
        draw:bar(player:get("hp"), player:get("max_hp"), color.hp, color.gray48, 40, "HP: ", "#", 6, 4)
        draw:icon(mp, x, y + 1, color.mp)
        draw:bar(player:get("mp"), player:get("max_mp"), color.mp, color.gray48, 40, "MP: ", "#", 6, 5)
        draw:icon(xp, x, y + 2, color.xp)
        draw:bar(player:get("xp"), player:get("max_xp"), color.xp, color.gray48, 40, "XP: ", "#", 6, 6)
        draw:icon(gp, x, y + 3, color.gp)
        draw:text("Gold: %d" % {player:get("gp")}, 6, 7)
    end,
    
    
    -- SCREENS --
    
    
    camp = function(self)
        self.init(38, "image/camp")
        
        draw:text("%s [Lvl 1 Warrior]" % {player:get("name")}, 4, 3)
        
        draw:icon(hp, 4, 4, color.hp)
        draw:bar(player:get("hp"), player:get("max_hp"), color.hp, color.gray48, 40, "HP: ", "#", 6, 4)
        draw:icon(mp, 4, 5, color.mp)
        draw:bar(player:get("mp"), player:get("max_mp"), color.mp, color.gray48, 40, "MP: ", "#", 6, 5)
        draw:icon(xp, 4, 6, color.xp)
        draw:bar(player:get("xp"), player:get("max_xp"), color.xp, color.gray48, 40, "XP: ", "#", 6, 6)
        draw:icon(gp, 4, 7, color.gp)
        draw:text("Gold: %d" % {player:get("gp")}, 6, 7)
        
        draw:options({"Map", "Character", "Rest", "Options"}, 4, 9)
        draw:text("- Press a letter.", 4, 17)
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
    if key == "a" then player:add("xp", -math.ceil(player:get("max_xp") / 10)) end
    if key == "d" then player:add("xp", math.ceil(player:get("max_xp") / 10)) end
end

function love.update(dt)
    
end

function love.draw()
    screen:update(0)
end