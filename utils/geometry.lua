bgml.geometry = {}

function bgml.geometry.cube(origin, fromlen)
    return vector.subtract(origin, fromlen), vector.add(origin, fromlen)
end
