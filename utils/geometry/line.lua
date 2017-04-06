bgml.geometry.line = {}
local lmt = {}

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
    return self:collide_box(bgml.cube.frombox(obj:get_properties().collisionbox), obj:getpos(), ...)
end

function bgml.geometry.line.new(start, finish)
    return setmetatable({
            start = start,
            finish = finish,
    }, {__index = lmt, __call = bgml.geometry.line.new})
end

bgml.line = setmetatable(bgml.geometry.line, {__call = function(self, ...) return bgml.geometry.line.new(...) end, __index = lmt})
