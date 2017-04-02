-- Calls the mod beginning hooks, returns a fresh mod table.
function bgml.mod.begin_mod()
    local modname = minetest.get_current_modname()
    bgml.hooks.global:call("mod_begin", modname)
    bgml.hooks.global:call("mod_begin:"..modname)

    return {
        dofile = bgml.mod.domodfile_factory(),
        ready = bgml.mod.ready_mod_factory(),
        hooks = bgml.hooks.new(),
        log = bgml.logging.log_factory(modname),
    }
end

-- Returns a function that calls the mod ready hooks.
function bgml.mod.ready_mod_factory()
    local modname = minetest.get_current_modname()
    return function()
        bgml.hooks.global:call("mod_ready", modname)
        bgml.hooks.global:call("mod_ready:"..modname)
    end
end

-- Logging hooks.
bgml.hooks.global:add("mod_begin", "bgml:mod_begin_logger", function(modname)
    bgml.log.info("[bgml.mod] begin: "..modname)
end)

bgml.hooks.global:add("mod_ready", "bgml:mod_begin_logger", function(modname)
    bgml.log(minetest.setting_getbool("log_mods") and "action" or "info", "[bgml.mod] ready: "..modname)
end)
