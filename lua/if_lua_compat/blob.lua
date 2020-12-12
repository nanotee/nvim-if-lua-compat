--- Wrapper class to interact with blobs
--- @class Blob

local Blob

--- @param bytes_str string|number
--- @return table<number, number>
local function string_to_bytes(bytes_str)
    if type(bytes_str) == 'number' then bytes_str = tostring(bytes_str) end
    if type(bytes_str) ~= 'string' then error('string expected, got ' .. type(bytes_str)) end
    local bytes = {}
    for char in vim.gsplit(bytes_str, '') do
        table.insert(bytes, string.byte(char))
    end
    return bytes
end

local blob_methods = {
    --- @param self Blob
    --- @param bytes_str string|number
    add = function(self, bytes_str)
        for _, byte in ipairs(string_to_bytes(bytes_str)) do
            table.insert(self, byte)
        end
    end,
}

local blob_mt = {
    type = 'blob',
    __index = blob_methods,
    __newindex = function(blob, key, value)
        if type(key) == 'number' then rawset(blob, key, value) end
        return
    end,
    __len = function(blob) return rawlen(blob) + 1 end,
}

--- @param bytes_str string|number
--- @return Blob
function Blob(bytes_str)
    local blob = {}
    for idx, byte in ipairs(string_to_bytes(bytes_str)) do
        blob[idx - 1] = byte
    end
    return setmetatable(blob, blob_mt)
end

return Blob
