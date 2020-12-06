local api = vim.api
local fn = vim.fn

local Buffer

local buf_methods = {
    insert = function(self, newline, pos)
        api.nvim_buf_set_lines(self.number, pos or -1, pos or -1, false, {newline})
    end,
    isvalid = function(self)
        return api.nvim_buf_is_valid(self.number)
    end,
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
    number = function(bufnr)
        return bufnr
    end,
    fname = function(bufnr)
        return api.nvim_buf_get_name(bufnr)
    end,
    name = function(bufnr)
        return fn.bufname(bufnr)
    end,
}

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

    local mt = {}

    mt.type = 'buffer'

    function mt.__index(_, key)
        if type(key) == 'number' then
            return api.nvim_buf_get_lines(bufnr, key - 1, key, false)[1]
        end
        if buf_methods[key] then return buf_methods[key] end
        if buf_getters[key] then return buf_getters[key](bufnr) end
    end
    function mt.__newindex()
        return
    end
    function mt.__call()
        api.nvim_set_current_buf(bufnr)
    end
    -- Only works with Lua 5.2+ or LuaJIT built with 5.2 extensions
    function mt.__len()
        return api.nvim_buf_line_count(bufnr)
    end

    return setmetatable({}, mt)
end

return Buffer
