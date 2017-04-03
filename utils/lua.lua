bgml.lutils = {}

-- Return an array-table of `t`'s keys.
function bgml.lutils.keys(t)
    local ret = {}
    for k in pairs(t) do
        table.insert(ret, k)
    end
    return ret
end

-- Return a combined table from all parameters. Later parameters override earlier parameters.
function bgml.lutils.combine(...)
    local ret = {}
    for _,t in ipairs({...}) do
        for k,v in pairs(t) do
            ret[k] = v
        end
    end
    return ret
end

-- Get the number of keys in any table.
function bgml.lutils.length(t)
    local ret = 0
    for _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

-- Return a shuffled table.
function bgml.lutils.shuffled(t)
    local ret = {}
    local copy = table.copy(t)
    while #copy > 0 do
        local index = math.random(1, #copy)
        table.insert(ret, copy[index])
        table.remove(copy, index)
    end
    return ret
end

-- Return a sorted iterator.
function bgml.lutils.spairs(t, f)
    local keys = bgml.lutils.keys(t)
    if f then
        table.sort(keys, function(a, b) return f(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


local function filterx(iter, t, f)
    local ret = {}
    for k,v in iter(t) do
        if f(t, k, v) then
            ret[k] = v
        end
    end
    return ret
end

-- Filter an array.
function bgml.lutils.filteri(...)
    return filterx(ipairs, ...)
end

-- Filter a table.
function bgml.lutils.filter(...)
    return filterx(pairs, ...)
end

if bgml.internal.config.lutils_full then
    table.combine = bgml.lutils.combine
    table.filter = bgml.lutils.filter
    table.filteri = bgml.lutils.filteri
    table.keys = bgml.lutils.keys
    table.length = bgml.lutils.length
    table.shuffled = bgml.lutils.shuffled
    table.spairs = bgml.lutils.spairs
end
