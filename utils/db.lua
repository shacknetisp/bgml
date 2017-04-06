bgml.db = {
    -- Manage databases to be saved.
    save_queue = {},
    save_pending = {},
    save_registry = {},

    load_hold = {},

    -- Table of databases.
    tables = {},
}

-- Metatable for each database.
local dmt = {}

-- Returns the base path for a database.
local function basepath(name)
    return bgml.internal.config.db_path .. DIR_DELIM .. name
end

-- Attempt to load the database, create an empty database if it doesn't exist.
function dmt:load()
    self.last_save = os.time()
    self.data = bgml.db.load_hold[self.name] or {}
end

-- Save the database robustly.
function dmt:save()
    bgml.hooks.global:call("db_saving:"..self.name)
    local f = io.open(self.tmppath, "w")
    if not f then
        error("Unable to save database to: "..self.tmppath)
    end
    f:write(minetest.serialize(self.data))
    f:close()
    if not os.rename(self.tmppath, self.path) then
        error("Unable to rename temporary database to: "..self.path)
    end
    self.last_save = os.time()
    bgml.hooks.global:call("db_saved:"..self.name)
end

-- Only alphanumeric, :, and _ are allowed in database names.
local function check(name)
    if name:match("[^%w:_]") then
        return false
    end
    return true
end

-- Create a database `name` that saves every `save_interval` seconds.
function bgml.db.new(name, save_interval)
    if not check(name) then
        error("Invalid database name: "..name)
    end

    local save_interval = save_interval or bgml.internal.config.save_interval
    bgml.db.tables[name] = setmetatable({
        name = name,
        path = basepath(name),
        tmppath = basepath(name) .. ".tmp",
        last_save = 0,
    }, {__index = dmt})
    bgml.db.save_registry[name] = save_interval
    bgml.db.tables[name]:load()
    return bgml.db.tables[name].data, bgml.db.tables[name]
end

minetest.register_globalstep(function(dtime)
    -- Check if any databases need added to the save queue.
    for name,t in pairs(bgml.db.tables) do
        if not bgml.db.save_pending[name] and (os.time() - t.last_save) > bgml.db.save_registry[name] then
            table.insert(bgml.db.save_queue, name)
            bgml.db.save_pending[name] = true
        end
    end
    -- Loop through the save queue and save as many databases as allowed.
    local num = bgml.internal.config.db_save_per_step
    while #bgml.db.save_queue > 0 and num > 0 do
        num = num - 1
        local name = table.remove(bgml.db.save_queue, 1)
        bgml.db.save_pending[name] = nil
        bgml.db.tables[name]:save()
    end
end)

-- Save all databases at shutdown time.
minetest.register_on_shutdown(function()
    bgml.hooks.global:call("db_shutdown_begin")
    for name,t in pairs(bgml.db.tables) do
        t:save()
    end
    bgml.hooks.global:call("db_shutdown_end")
end)

if bgml.internal.config.db_cleaner then
    bgml.hooks.global:add("db_shutdown_end", "bgml:db_cleaner", function()
        for _,name in ipairs(minetest.get_dir_list(bgml.internal.config.db_path), false) do
            if not bgml.db.tables[name] then
                if not os.remove(basepath(name)) then
                    error("Could not remove database: "..name)
                end
                bgml.log.info("[bgml.db] Removed old database: "..name)
            end
        end
    end)
end

bgml.hooks.global:add("db_shutdown_end", "bgml:db_logger", function()
    bgml.log.info("[bgml.db] All databases saved due to shutdown.")
end)

minetest.mkdir(bgml.internal.config.db_path)

-- Preload all databases into the holding table.
local num = 0
for _,name in ipairs(minetest.get_dir_list(bgml.internal.config.db_path), false) do
    local f = io.open(basepath(name), "r")
    if f then
        bgml.db.load_hold[name] = minetest.deserialize(f:read("*all"))
        f:close()
    else
        error("Unreadable database in the db path: "..name)
    end
    num = num + 1
end
bgml.log.info("[bgml.db] Databases loaded: "..tostring(num))
