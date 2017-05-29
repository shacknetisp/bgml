bgml.require("core/logging")
bgml.config = {}

-- Returns a config table.
-- somemod.config_table['some_index'] = true
--- somemod.config_table.some_index == true
-- somemod.config_table['some_index'] = true
-- [minetest.conf] somemodname.some_index = false
--- somemod.config_table.some_index == false
function bgml.config.config_factory()
    local modname = minetest.get_current_modname()

    -- This function wraps around minetest.setting_get[bool] to check if the default should be overriden.
    local function get(setting, default)
        if type(default) == "boolean" then
            local read = minetest.settings:get_bool(modname.."."..setting)
            if read == nil then
                return default
            else
                return read
            end
        elseif type(default) == "string" then
            return minetest.settings:get(modname.."."..setting) or default
        elseif type(default) == "number" then
            return tonumber(minetest.settings:get(modname.."."..setting) or default)
        else
            error(("Unknown format for configuration key '%s': %s"):format(setting, type(default)))
        end
    end

    -- The returned table should set defaults upon a new index, and use get() upon an index.
    return setmetatable({
        _defaults = {},
    }, {
        __index = function(self, key)
            local default = self._defaults[key]
            -- If there is no default then the setting should not be used.
            if default == nil then
                return error(("'%s' is not a configuration option"):format(key))
            end
            return get(key, default)
        end,
        __newindex = function(self, key, value)
            self._defaults[key] = value
            if bgml.internal.config.log_config then
                bgml.internal.log(("[config] %s.%s = %s (default: %s)"):format(modname, tostring(key), dump(get(key, value)), dump(value)))
            end
        end,
    })
end
