bgml.geometry.box = {}
local cmt = {}

-- Test if the box has collided with a box at pos.
function cmt:collide_box(box, pos)
    local box = pos and box:translated(pos) or box

    local e = {
        a = self:extremes(),
        b = box:extremes(),
    }

    local function beyond(axis)
        if e.a.min[axis] < e.b.min[axis] and e.a.max[axis] < e.b.min[axis] then
            return true
        elseif e.a.min[axis] > e.b.max[axis] and e.a.max[axis] > e.b.max[axis] then
            return true
        elseif e.b.min[axis] < e.a.min[axis] and e.b.max[axis] < e.a.min[axis] then
            return true
        elseif e.b.min[axis] > e.a.max[axis] and e.b.max[axis] > e.a.max[axis] then
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

-- Test if the box has collided with an entity.
function cmt:collide_object(obj, ...)
    return self:collide_box(bgml.geometry.box.fromcbox(obj:get_properties().collisionbox), obj:getpos(), ...)
end

-- Get the extremes of the box.
function cmt:extremes()
    return {
        min = vector.new(math.min(self.a.x, self.b.x), math.min(self.a.y, self.b.y), math.min(self.a.z, self.b.z)),
        max = vector.new(math.max(self.a.x, self.b.x), math.max(self.a.y, self.b.y), math.max(self.a.z, self.b.z)),
    }
end

-- Get the box translated to a position
function cmt:translated(pos)
    return bgml.geometry.box.new(vector.add(pos, self.a), vector.add(pos, self.b))
end

-- From corners.
function bgml.geometry.box.new(a, b)
    return setmetatable({
            a = a,
            b = b,
    }, {__index = cmt})
end

-- From origin.
function bgml.geometry.box.fromorigin(origin, fromlen)
    return bgml.geometry.box.new(vector.subtract(origin, fromlen), vector.add(origin, fromlen))
end

-- From entity collision box.
function bgml.geometry.box.fromcbox(box)
    return bgml.geometry.box.new(vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6]))
end

bgml.box = setmetatable(bgml.geometry.box, {__call = function(self, ...) return bgml.geometry.box.new(...) end, __index = cmt})
