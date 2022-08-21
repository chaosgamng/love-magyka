getmetatable("").__mod = function(a, b)
    if not b then
        return a
    elseif type(b) == "table" then
        return string.format(a, unpack(b))
    else
        return string.format(a, b)
    end
end

function export(class)
    local t = {}
    local mt = getmetatable(class).__index
    updateTable(mt, class)
    
    for k, v in pairs(mt) do
        if type(v) == "table" then
            local nested = v
            if v[export] then nested = v:export() end
            
            t[k] = nested
        elseif type(v) ~= "function" then
            t[k] = v
        end
    end
    
    return t
end

function dumpTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s..'['..k..'] = '..dumpTable(v).. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function updateTable(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end
end

function appendTable(t1, t2)
    for k, v in pairs(t2) do table.insert(t1, v) end
end

function rand(range)
    local a = range[1]
    local b = range[2]
    if a > b then
        a = range[2]
        b = range[1]
    end
    
    return math.random(a, b)
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