function bgml.to_player(x)
    if type(x) == "string" then
        return minetest.get_player_by_name(x)
    end
    return x
end

function bgml.to_player_name(x)
    if type(x) == "string" then
        return x
    end
    return x:get_player_name()
end
