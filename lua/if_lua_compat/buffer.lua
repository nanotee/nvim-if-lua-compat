local api = vim.api
local fn = vim.fn

--- Wrapper to interact with buffers
--- @class Buffer

local Buffer

--- Use a table reference as a key to make certain fields inaccessible outside of the module
local private_bufnr = {}

local buf_methods = {
    --- @param self    Buffer
    --- @param newline string
    --- @param pos     number
    insert = function(self, newline, pos)
        api.nvim_buf_set_lines(self.number, pos or -1, pos or -1, false, {newline})
    end,

    --- @param self Buffer
    --- @return boolean
    isvalid = function(self)
        return api.nvim_buf_is_valid(self.number)
    end,

    --- @param self Buffer
    --- @return Buffer|nil
    next = function(self)
        local bufnr = self.number
        local buffers = api.nvim_list_bufs()
        local next_buf
        for k, v in ipairs(buffers) do
            if v == bufnr then
                next_buf = k + 1
                break
            end
        end
        if next_buf and buffers[next_buf] then
            return Buffer(buffers[next_buf])
        end
        return nil
    end,

    --- @param self Buffer
    --- @return Buffer|nil
    previous = function(self)
        local bufnr = self.number
        local buffers = api.nvim_list_bufs()
        local prev_buf
        for k, v in ipairs(buffers) do
            if v == bufnr then
                prev_buf = k - 1
                break
            end
        end
        if prev_buf and buffers[prev_buf] then
            return Buffer(buffers[prev_buf])
        end
        return nil
    end,
}

local buf_getters = {
    --- @param bufnr number
    --- @return number
    number = function(bufnr)
        return bufnr
    end,

    --- @param bufnr number
    --- @return string
    fname = function(bufnr)
        return api.nvim_buf_get_name(bufnr)
    end,

    --- @param bufnr number
    --- @return string
    name = function(bufnr)
        return fn.bufname(bufnr)
    end,
}

local buf_mt = {
    type = 'buffer',
    __index = function(tbl, key)
        if type(key) == 'number' then
            return api.nvim_buf_get_lines(tbl[private_bufnr], key - 1, key, false)[1]
        end
        if buf_methods[key] then return buf_methods[key] end
        if buf_getters[key] then return buf_getters[key](tbl[private_bufnr]) end
    end,
    __newindex = function() return end,
    __call = function(tbl)
        api.nvim_set_current_buf(tbl[private_bufnr])
    end,
    -- Only works with Lua 5.2+ or LuaJIT built with 5.2 extensions
    __len = function(tbl)
        return api.nvim_buf_line_count(tbl[private_bufnr])
    end,
}

--- @param arg ?string|number|boolean|table
--- @return Buffer|nil
function Buffer(arg)
    local buffers = api.nvim_list_bufs()
    local bufnr
    if arg then
        bufnr = buffers[1]
    else
        bufnr = api.nvim_get_current_buf()
    end

    if type(arg) == 'string' then
        bufnr = fn.bufnr(arg)
        if bufnr == -1 then return nil end
    end
    if type(arg) == 'number' then
        if not api.nvim_buf_is_valid(arg) then return nil end
        bufnr = arg
    end

    return setmetatable({[private_bufnr] = bufnr}, buf_mt)
end

return Buffer
