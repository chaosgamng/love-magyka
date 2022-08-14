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

function isInRange(str, low, high)
    num = tonumber(str)
    if str:match("^%-?%d+$") and num >= low and num <= high then return true else return false end
end

function count(str, subString)
    return select(2, str:gsub(subString, ""))
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end