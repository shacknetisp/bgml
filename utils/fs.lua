bgml.fsutils = {}

function bgml.fsutils.exists(path)
    local f = io.open(path)
    if f then
        f:close()
        return true
    end
    return false
end

function bgml.fsutils.split_path(path)
    local ret = {}
    local last = nil
    for segment in path:gmatch("[^"..DIR_DELIM.."]+") do
        table.insert(ret, segment)
        last = segment
    end
    if #ret > 0 then
        table.remove(ret, #ret)
    end
    return (#ret > 0) and (DIR_DELIM .. table.concat(ret, DIR_DELIM)) or nil, last
end

local function is_x(path, type)
    local dir, name = bgml.fsutils.split_path(path)
    for _,n in ipairs(minetest.get_dir_list(dir, type)) do
        if n == name then
            return true
        end
    end
    return false
end

function bgml.fsutils.is_file(path)
    return is_x(path, false)
end

function bgml.fsutils.is_dir(path)
    return is_x(path, true)
end
