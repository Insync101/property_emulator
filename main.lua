local mt = getrawmetatable(game)
local index, newindex = mt.__index, mt.__newindex
local emulated = {}

setreadonly(mt, false)

local meta_hooks = {
    __index = function(self, prop)
        local A = emulated[self]
        local B = A and A[prop]

        if A and B then
            return B[1]
        end

        return index(self, prop)
    end,
    __newindex = function(self, prop, value)
        local A = emulated[self]
        local B = A and A[prop]
        local virtual_instance

        local success = pcall(function()
            virtual_instance = Instance.new(self.ClassName)
        end)

        if success then
            pcall(newindex, virtual_instance, prop, value)
        end

        if A and B then
            local caller = checkcaller()
            if not caller then
                B[1] = virtual_instance and virtual_instance[prop] or value
            else
                B[2] = value
            end

            value = B[2]
        end

        if virtual_instance then
            virtual_instance:Destroy()
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
