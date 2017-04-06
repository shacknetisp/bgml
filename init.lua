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

    -- Directory found, build the function.
    -- Load `path`, force it to be interpreted as a directory if `forcedir` is true.
    bgml["_require_"..modname] = function(path, iter)
        local iter = iter or 1
        if iter > MAX_REQUIRE_ITERS then
            error("_require_"..modname .. " iterated more than "..tostring(MAX_REQUIRE_ITERS))
        end
        local full_path = modpath .. DIR_DELIM .. path
        -- Automatically attempt to add .lua
        if not bgml.fsutils.exists(full_path) and bgml.fsutils.is_file(full_path .. ".lua") then
            full_path = full_path .. ".lua"
        end
        if not bgml.fsutils.exists(full_path) then
            error("Unable to load file: "..full_path)
        end
        if bgml.fsutils.is_file(full_path) then
            -- If the file's already loaded, it's not a good idea to load it again.
            if bgml._loaded[full_path] then
                return
            end
            bgml._loaded[full_path] = true
            -- Swap out bgml.require for the current mod's require function.
            local oldreq = bgml.require
            bgml.require = bgml["_require_"..modname]
            dofile(full_path)
            bgml.require = oldreq
            return
        end
        -- Try to execute an init.lua in the directory first.
        local init_path = path .. DIR_DELIM .. "init.lua"
        local full_init_path = modpath .. DIR_DELIM .. init_path
        if bgml.fsutils.is_file(full_init_path) then
            bgml["_require_"..modname](init_path)
        end
        -- Loop through everything in this directory and call the function again on it.
        for _,n in ipairs(minetest.get_dir_list(full_path)) do
            if n ~= "init.lua" then
                bgml["_require_"..modname](path .. DIR_DELIM .. n, iter + 1)
            end
        end
    end
    return bgml["_require_"..modname]
end

-- The fsutils must be loaded manually in order to use BGML's require.
local fsutils_path = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM .. "utils" .. DIR_DELIM .. "fs.lua"
bgml._loaded[fsutils_path] = true
dofile(fsutils_path)

-- Create BGML's own loader.
bgml.internal.require = bgml.mod.require_factory()

-- Load the rest of the core.
bgml.internal.require("core")

-- Now BGML can be initialized normally.
bgml.internal = bgml.mod.begin()

-- Load default settings.
bgml.internal.require("defaults")

-- Execute the rest of BGML.
bgml.internal.require("utils")
bgml.internal.require("minetest")

-- And we're done!
bgml.internal.ready()
