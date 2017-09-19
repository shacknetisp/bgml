bgml.require("core/hooks")
bgml.require("core/logging")
-- Calls the mod beginning hooks, returns a fresh mod table.
function bgml.mod.begin()
    local modname = engine.get_current_modname()
    local modtable = {
        require = bgml.mod.require_factory(),
        ready = bgml.mod.ready_mod_factory(),
        log = bgml.logging.log_factory(modname),

        hooks = bgml.hooks.new(),
        config = bgml.config.config_factory(),
    }
    bgml.hooks.global:call("mod_begin", modname, modtable)
    bgml.hooks.global:call("mod_begin:"..modname, modtable)

    return modtable
end

-- Returns a function that calls the mod ready hooks.
function bgml.mod.ready_mod_factory()
    local modname = engine.get_current_modname()
    return function()
        bgml.hooks.global:call("mod_ready", modname)
        bgml.hooks.global:call("mod_ready:"..modname)
    end
end

-- Logging hooks.
bgml.hooks.global:add("mod_begin", "bgml:mod_logger", function(modname)
    if bgml.internal.log then
        bgml.internal.log.info("[mod] begin: "..modname)
    else
        bgml.log.info("[bgml.mod] begin: "..modname)
    end
end)

bgml.hooks.global:add("mod_ready", "bgml:mod_logger", function(modname)
    bgml.internal.log(bgml.internal.config.log_mods and "none" or "info", "[mod] ready: "..modname)
end)
