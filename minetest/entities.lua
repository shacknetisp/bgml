bgml.entities = {
    permanent = bgml.db.new("permanent_entities"),
    loaded = {},
}

minetest.register_globalstep(function(dtime)
    local to_unload = {}
    for id,ext in pairs(bgml.entities.loaded) do
        if not ext.object then
            table.insert(to_unload, ext)
        elseif not ext.object:getpos() then
            if ext.def.on_unload then
                ext.def.on_unload(nil, ext)
            end
            table.insert(to_unload, ext)
        end
    end
    for _,ext in ipairs(to_unload) do
        bgml.entities.loaded[ext.id] = nil
    end
end)

function bgml.register_entity(name, def)
    minetest.register_entity(name, bgml.lutils.combine(def, {
        on_activate = function(self, staticdata, dtime)
            if #staticdata <= 0 then
                if def.permanent then
                    bgml.internal.log.error("[bgml.entities] Removed permanent entity "..name.." due to empty staticdata at "..minetest.pos_to_string(self.object:getpos()))
                end
                self.object:remove()
                return
            end
            self.ext = {
                id = staticdata,
                def = def,
            }
            if def.permanent then
                if bgml.entities.permanent[staticdata] then
                    self.ext = bgml.entities.permanent[staticdata]
                else
                    bgml.internal.log.error("[bgml.entities] Unable to locate entity "..name.." with id "..staticdata.." at "..minetest.pos_to_string(self.object:getpos()).." in the entity table.")
                    self.object:remove()
                    return
                end
            end
            self.ext.entity = self
            self.ext.object = self.object
            for _,c in ipairs({def.on_activate or false, def.on_load or false}) do
                if c then
                    c(self, staticdata, dtime)
                end
            end
            bgml.entities.loaded[self.ext.id] = self.ext
        end,
        get_staticdata = function(self)
            if not self.permanent then
                return
            end
            for _,c in ipairs({def.on_save or false}) do
                if c then
                    c(self)
                end
            end
            return self.ext.id
        end,
    }))
end

function bgml.add_entity(pos, name, param)
    local ext = {
        id = bgml.utils.uid(),
        def = minetest.registered_entities[name],
        param = param,
    }
    if ext.def.permanent then
        bgml.entities.permanent[ext.id] = ext
    end
    local obj = minetest.add_entity(pos, name, tostring(ext.id))
    if obj then
        ext.object = obj
        for _,c in ipairs({ext.def.on_creation or false, ext.def.on_load or false}) do
            if c then
                c(obj:get_luaentity(), ext.id, 0)
            end
        end
        return obj, ext
    end
end
