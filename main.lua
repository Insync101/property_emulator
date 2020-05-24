local mt = getrawmetatable(game)
local index, newindex = mt.__index, mt.__newindex
local emulated = {}

setreadonly(mt, false)

local meta_hooks = {
    ['__index'] = function(self, prop)
        local A = emulated[self] or nil
        local B = A and A[prop] or nil

        if A and B then
            return B[1]
        end

        return index(self, prop)
    end,
    ['__newindex'] = function(self, prop, value)
        local A = emulated[self] or nil
        local B = A and A[prop] or nil

        if A and B then
            local caller = checkcaller()
            if not caller then
                B[1] = value
            else
                B[2] = value
            end

            value = B[2]
        end

        return newindex(self, prop, value)
    end
}

for index, method in next, meta_hooks do
    mt[index] = newcclosure(method)
end

local function emulate_property(self, prop)
    if emulated[self] then
        emulated[self][prop] = {self[prop], self[prop]}
    else
        emulated[self] = {}
        emulate_property(self, prop)
    end 
end

return emulate_property
