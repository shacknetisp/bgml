-- Beha's General Minetest Library
-- init.lua, the bootstrapping file.

bgml = {
    -- Functions intended for use by BGML itself. BGML's own mod table is here.
    internal = {},
    -- Loaded lua files.
    _loaded = {},
    -- This table is created here instead of in mod.lua due to the requirement of defining domodfile_factory in init.lua
    mod = {},
}

local MAX_REQUIRE_ITERS = 10

-- First we need a way to load the rest of BGML. Thus the dofile wrapper system is in init.lua

-- Generate the `require` function.
function bgml.mod.require_factory()
    -- Attempt to locate our directory.
    local modname = minetest.get_current_modname()
    local modpath = minetest.get_modpath(modname)
    if modpath == nil then
        error("minetest.get_modpath for "..modname.." returned nil.")
    end

    local function is_readable(path)
        local f = io.open(path)
        if not f then
            return false
        end
        local ret = false
        if f:read(1) then
            ret = true
        end
        f:close()
        return ret
    end

    -- Directory found, build the function.
    -- Load `path`, force it to be interpreted as a directory if `forcedir` is true.
    bgml["_require_"..modname] = function(path, forcedir, iter)
        local iter = iter or 1
        if iter > MAX_REQUIRE_ITERS then
            error("_require_"..modname .. " iterated more than "..tostring(MAX_REQUIRE_ITERS))
        end
        local full_path = modpath .. DIR_DELIM .. path
        -- Automatically attempt to add .lua
        if not is_readable(full_path) and is_readable(full_path .. ".lua") and not forcedir then
            full_path = full_path .. ".lua"
        end
        -- Load this as a file if it's readable.
        if is_readable(full_path) and not forcedir then
            -- If the file's already loaded, it's not a good idea to load it again.
            if bgml._loaded[full_path] then
                return
            end
            bgml._loaded[full_path] = true
            local oldreq = bgml.req
            bgml.req = bgml["_require_"..modname]
            dofile(full_path)
            bgml.req = oldreq
            return
        end
        -- Loop through everything in this directory and call the function again on it.
        for _,n in ipairs(minetest.get_dir_list(full_path)) do
            bgml["_require_"..modname](path .. DIR_DELIM .. n, iter + 1)
        end
    end
    return bgml["_require_"..modname]
end

-- Create BGML's own loader.
bgml.internal.require = bgml.mod.require_factory()

bgml.internal.require("core")

-- Now BGML can be initialized normally.
bgml.internal = bgml.mod.begin()

-- Load default settings.
bgml.internal.require("defaults")

-- Execute the rest of BGML.
bgml.internal.require("utils")

-- And we're done!
bgml.internal.ready()
