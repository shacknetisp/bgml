-- Beha's General Minetest Library
-- init.lua, the bootstrapping file.

bgml = {
    -- Functions intended for use by BGML itself.
    internal = {},
    -- This table is created here instead of in mod.lua due to the requirement of defining domodfile_factory in init.lua
    mod = {},
}

-- First we need a way to load the rest of BGML. Thus the dofile wrapper system is in init.lua

-- Generate a `domodfile` function.
function bgml.mod.domodfile_factory()
    -- Attempt to locate our directory.
    local modname = minetest.get_current_modname()
    local modpath = minetest.get_modpath(modname)
    if modpath == nil then
        error("minetest.get_modpath for "..modname.." returned nil.")
    end
    -- Directory found, build the function.
    return function(path)
        return dofile(modpath .. DIR_DELIM .. path)
    end
end

-- Create BGML's own domodfile.
bgml.internal.dofile = bgml.mod.domodfile_factory()

-- These functions are used in mod.lua and must be loaded before the proper mod table can be created.
bgml.internal.dofile("logging.lua")
bgml.internal.dofile("hooks.lua")
bgml.internal.dofile("config.lua")

-- Next we need to load mod.lua in order for BGML to create it's own mod table appropriately.
bgml.internal.dofile("mod.lua")

-- Now BGML can be initialized normally.
bgml.internal = bgml.mod.begin()

-- Load default settings.
bgml.internal.dofile("defaults.lua")

-- Execute the rest of BGML.
bgml.internal.dofile("lutils.lua")
bgml.internal.dofile("db.lua")

-- And we're done!
bgml.internal.ready()
