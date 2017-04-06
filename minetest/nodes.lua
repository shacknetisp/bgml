local BLOCK_SIZE = 16

-- Get node, even if unloaded. Will load node's block.
function bgml.get_node(pos)
    local node = minetest.get_node_or_nil(pos)
    if node then
        return node
    end
    VoxelManip():read_from_map(pos, pos)
    return bgml.get_node(pos)
end


local function get_nodes_x(f, origin, fromlen, names)
    local minpos, maxpos = bgml.cube.fromorigin(origin, fromlen)
    return f(minpos, maxpos, names)
end

-- Search for nodes in a cube.
-- ...(origin, fromlen, names)
function bgml.get_nodes_in_cube(...)
    return get_nodes_x(minetest.find_nodes_in_area, ...)
end

-- Search for nodes under air in a cube.
-- ...(origin, fromlen, names)
function bgml.get_nodes_in_cube_under_air(...)
    return get_nodes_x(minetest.find_nodes_in_area_under_air, ...)
end

-- Get the mapblock a node belongs to.
function bgml.node_to_block(pos)
    return vector.apply(pos, function(a) return math.floor(a / BLOCK_SIZE) end)
end

-- Get the boundaries of a mapblock.
function bgml.block_to_cube(pos)
    local origin = vector.multiply(pos, BLOCK_SIZE)
    return bgml.cube.new(origin, vector.add(origin, BLOCK_SIZE-1))
end
