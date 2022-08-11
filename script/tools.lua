getmetatable("").__mod = function(a, b)
    if not b then
        return a
    elseif type(b) == "table" then
        return string.format(a, unpack(b))
    else
        return string.format(a, b)
    end
end

function dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s..'['..k..'] = '..dump_table(v).. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function rand(range)
    return math.random(range[1], range[2])
end