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

if bgml.internal.config.lutils_full then
    table.combine = bgml.lutils.combine
    table.keys = bgml.lutils.keys
end
