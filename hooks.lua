bgml.hooks = {}

-- Metatable for hook tables.
bgml.hooks._hooks_metatable = {}
local hmt = bgml.hooks._hooks_metatable

-- Add `callback` to `hook` with `name`.
function hmt:add(hook, name, callback)
    self:hook_list(hook)[name] = callback
end

-- Remove `name` from `hook`.
function hmt:remove(hook, name)
    local existed = (self:hook_list(hook)[name] ~= nil)
    self:hook_list(hook)[name] = nil
    return existed
end

-- Call `hook` with `...`.
function hmt:call(hook, ...)
    local ret = false
    for name,callback in pairs(self:hook_list(hook)) do
        callback(...)
        ret = true
    end
    return ret
end

-- Get table of callbacks for `hook`.
function hmt:hook_list(hook)
    -- Ensure the base hook table exists.
    self._hooks = self._hooks or {}
    -- Ensure this hook's table exists.
    self._hooks[hook] = self._hooks[hook] or {}
    -- All's well, return the table.
    return self._hooks[hook]
end

function bgml.hooks.new()
    return setmetatable({}, {__index=hmt})
end

-- Create BGML's global hook table.
bgml.hooks.global = bgml.hooks.new()
