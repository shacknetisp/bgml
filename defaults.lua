-- Alias for readability
local c = bgml.internal.config

-- Logging

-- Output all configuration options registered through BGML.
--- bgml.log_config must be the first default, so that other config defaults can output when set.
c.log_config = false
-- Log mod_ready hooks. Defaults to the somewhat common log_mods setting.
c.log_mods = engine.settings:get_bool("log_mods") or false


-- Databases

-- Path in which to save database serializations.
c.db_path = engine.get_worldpath() .. DIR_DELIM .. "bgml" .. DIR_DELIM .. "db"
-- Default database save internal.
c.save_interval = 10
-- How many database files can be written per globalstep?
c.db_save_per_step = 2
-- Should databases not registered this run be removed?
c.db_cleaner = true
