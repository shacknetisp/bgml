bgml.geometry.line = {}
local lmt = {}


-- Get a reversed line.
function lmt:reversed()
    return bgml.geometry.line.new(self.finish, self.start)
end

-- Get the midpoint of the line.
function lmt:middle()
    return vector.divide(vector.add(self.start, self.finish), 2)
end

-- Get length of the line.
function lmt:length()
    return vector.distance(self.start, self.finish)
end

-- Test if the line has collided with a box at pos.
function lmt:collide_box(box, pos)
    local box = pos and box:translated(pos) or box

    local function beyond(axis)
        if self.start[axis] < box.a[axis] and self.finish[axis] < box.a[axis] then
            return true
        elseif self.start[axis] > box.b[axis] and self.finish[axis] > box.b[axis] then
            return true
        else
            return false
        end
    end

    for _,axis in ipairs({"x", "y", "z"}) do
        if beyond(axis) then
            return false
        end
    end

    return true

end

-- Test if the line has collided with an entity.
function lmt:collide_object(obj, ...)
    return self:collide_box(bgml.box.frombox(obj:get_properties().collisionbox), obj:getpos(), ...)
end


-- Thanks HybridDog! These functions are borrowed from the WTFPL-licensed mod 'vector_extras' (https://github.com/HybridDog/vector_extras)

local function scalar(v1, v2)
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

local function get_max_coord(vec)
    if vec.x < vec.y then
        if vec.y < vec.z then
                return "z"
        end
        return "y"
    end
    if vec.x < vec.z then
        return "z"
    end
    return "x"
end

-- Iterate through node positions the line passed through.
function lmt:passedi()
    local dir = vector.direction(self.start, self.finish)
    local len = self:length()

    -- make a table of possible movements
    local step = {}
    for i in pairs(self.start) do
        local v = math.sign(dir[i])
        if v ~= 0 then
            step[i] = v
        end
    end

    local p
    return function()
        if not p then
            -- avoid skipping the first position
            p = vector.round(self.start)
            return vector.new(p)
        end

        -- find the position which has the smallest distance to the line
        local choose = {}
        local choosefit = vector.new()
        for i in pairs(step) do
            choose[i] = vector.new(p)
            choose[i][i] = choose[i][i] + step[i]
            choosefit[i] = scalar(vector.normalize(vector.subtract(choose[i], self.start)), dir)
        end
        p = choose[get_max_coord(choosefit)]
        if p and vector.distance(self.start, p) <= len then
            return vector.new(p)
        end
    end
end

function bgml.geometry.line.new(start, finish)
    return setmetatable({
            start = start,
            finish = finish,
    }, {__index = lmt, __call = bgml.geometry.line.new})
end

bgml.line = setmetatable(bgml.geometry.line, {__call = function(self, ...) return bgml.geometry.line.new(...) end, __index = lmt})
