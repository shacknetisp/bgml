bgml.entities = {
    loaded = {},
}

minetest.register_globalstep(function(dtime)
    local to_unload = {}
    for id,v in pairs(bgml.entities.loaded) do
        -- If the object is inaccessible, and therefore unloaded:
        if not v.object:getpos() then
            -- Call on_unload.
            if v.def.on_unload then
                v.def.on_unload(nil, v.ext)
            end
            -- Insert into the removal queue.
            table.insert(to_unload, id)
        end
    end
    -- Clear all unloaded entities.
    for _,id in ipairs(to_unload) do
        bgml.entities.loaded[id] = nil
    end
end)

function bgml.register_entity(name, def)
    minetest.register_entity(name, bgml.lutils.combine(def, {
        on_activate = function(self, staticdata, dtime)
            -- Remove non-permanent entities if they are activated after creation time.
            if not def.permanent and dtime > 0.001 then
                self.object:remove()
                return
            end

            -- If an entity has no static data then destroy it.
            if #staticdata <= 0 then
                bgml.internal.log.error("[entities] Removed entity "..name.." due to empty staticdata at "..minetest.pos_to_string(self.object:getpos()))
                self.object:remove()
                return
            end

            -- Build extra/external properties from staticdata.
            self.ext = minetest.deserialize(staticdata)

            -- Call activation and load callbacks.
            for _,c in ipairs({def.on_activate or false, def.on_load or false}) do
                if c then
                    c(self, staticdata, dtime)
                end
            end

            -- This entity is now loaded.
            bgml.entities.loaded[self.ext.id] = {
                def = def,
                object = self.object,
                ext = self.ext,
            }
        end,
        get_staticdata = function(self)
            -- Only permanent entities should set their staticdata.
            if not def.permanent then
                return
            end

            -- Call saving callbacks.
            for _,c in ipairs({def.on_save or false}) do
                if c then
                    c(self)
                end
            end

            -- Return the serialized staticdata, excluding unwanted parts.
            return minetest.serialize(bgml.lutils.exclude(self.ext, {"param"}))
        end,
    }))
end

function bgml.add_entity(pos, name, param)
    -- Build the parameters
    local def = minetest.registered_entities[name]
    local ext = {
        id = bgml.utils.uid(),
    }
    local staticdata = minetest.serialize(ext)

    -- Create the object. The staticdata will be passed to on_activate.
    local obj = minetest.add_entity(pos, name, staticdata)
    -- If it was successful:
    if obj then
        -- Set the param, which can be accessed from on_creation or on_load.
        obj:get_luaentity().ext.param = param
        -- Call the creation callbacks.
        for _,c in ipairs({def.on_creation or false, def.on_load or false}) do
            if c then
                c(obj:get_luaentity(), staticdata, 0)
            end
        end
        -- Return the object and its ext table.
        return obj, obj:get_luaentity().ext
    end
end
