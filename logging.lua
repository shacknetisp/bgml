bgml.logging = {}

-- Returns a logging table. `modname` is optional.
-- log = log_factory([modname])
--- log([level], message)
--- log.level(message)
function bgml.logging.log_factory(modname)
    local lmt = {
        modname = modname or false,
        message = function(self, message)
            if self.modname then
                return ("[%s] %s"):format(self.modname, message)
            else
                return message
            end
        end,
    }
    return setmetatable({},
        {
            __index=function(self, k)
                if lmt[k] ~= nil then
                    return lmt[k]
                end
                return function(message)
                    return self(k, message)
                end
            end,
            __call=function(self, a, b)
                local level, message
                -- Define level if both a and b are not nil.
                level = b and a or nil
                -- Message should be whichever is last not nil.
                message = self:message(b or a)
                if level then
                    return minetest.log(level, message)
                else
                    return minetest.log(message)
                end
            end,
        }
    )
end

-- Create the global log table.
bgml.log = bgml.logging.log_factory()
