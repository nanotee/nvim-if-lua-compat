local fn = vim.fn
if fn.has('nvim') == 0 then return end

local api = vim.api

vim.command = api.nvim_command
vim.eval = api.nvim_eval
vim.line = api.nvim_get_current_line

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
    _type = function()
        return 'buffer'
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

vim.buffer = Buffer

vim.open = function(fname)
    local bufnr = api.nvim_create_buf(true, false)
    if fname then api.nvim_buf_set_name(bufnr, fname) end
    return Buffer(bufnr)
end

local Window

local win_methods = {
    isvalid = function(self)
        return api.nvim_win_is_valid(self.number)
    end,
    next = function(self)
        local winnr = self._winnr
        local windows = api.nvim_tabpage_list_wins(api.nvim_win_get_tabpage(winnr))
        local next_win
        for k, v in ipairs(windows) do
            if v == winnr then
                next_win = k + 1
                break
            end
        end
        if next_win and windows[next_win] then
            return Window(next_win)
        end
        return nil
    end,
    previous = function(self)
        local winnr = self._winnr
        local windows = api.nvim_tabpage_list_wins(api.nvim_win_get_tabpage(winnr))
        local prev_win
        for k, v in ipairs(windows) do
            if v == winnr then
                prev_win = k - 1
                break
            end
        end
        if prev_win and windows[prev_win] then
            return Window(prev_win)
        end
        return nil
    end,
}

local win_getters = {
    buffer = function(winnr)
        return Buffer(api.nvim_win_get_buf(winnr))
    end,
    line = function(winnr)
        return api.nvim_win_get_cursor(winnr)[1]
    end,
    col = function(winnr)
        return api.nvim_win_get_cursor(winnr)[2] + 1
    end,
    width = function(winnr)
        return api.nvim_win_get_width(winnr)
    end,
    height = function(winnr)
        return api.nvim_win_get_height(winnr)
    end,
    _type = function()
        return 'window'
    end,
    _winnr = function(winnr)
        return winnr
    end,
}

local win_setters = {
    line = function(winnr, line)
        return api.nvim_win_set_cursor(winnr, {line, 0})
    end,
    col = function(winnr, col)
        return api.nvim_win_set_cursor(winnr, {api.nvim_win_get_cursor(winnr)[1], col - 1})
    end,
    width = function(winnr, width)
        return api.nvim_win_set_width(winnr, width)
    end,
    height = function(winnr, height)
        return api.nvim_win_set_height(winnr, height)
    end,
}

function Window(arg)
    local windows = api.nvim_tabpage_list_wins(0)
    if type(arg) == 'number' and not windows[arg] then
        return nil
    end

    local winnr
    if windows[arg] then
        winnr = windows[arg]
    elseif arg then
        winnr = windows[1]
    else
        winnr = api.nvim_get_current_win()
    end

    local mt = {}
    function mt.__index(_, key)
        if win_methods[key] then return win_methods[key] end
        if win_getters[key] then return win_getters[key](winnr) end
    end
    function mt.__newindex(_, key, value)
        if win_setters[key] then return win_setters[key](winnr, value) end
        return error(('Invalid window property: %s'):format(key))
    end
    function mt.__call()
        api.nvim_set_current_win(winnr)
    end

    return setmetatable({}, mt)
end

vim.window = Window

vim.type = function(object)
    if type(object) ~= 'table' then return type(object) end
    if object._type then return object._type end
    return type(object)
end

local List

local list_methods = {
    add = function(self, item)
        table.insert(self, item)
    end,
    insert = function(self, item, position)
        if position then
            if position > #self then position = #self end
            if position < 0 then position = 0 end
            table.insert(self, position + 1, item)
        else
            table.insert(self, 1, item)
        end
    end,
}

local list_getters = {
    _type = function()
        return 'list'
    end,
}

function List(tbl)
    local list = {}
    for _, v in ipairs(tbl) do
        table.insert(list, v)
    end
    local mt = {}
    function mt.__index(_, key)
        if list_methods[key] then return list_methods[key] end
        if list_getters[key] then return list_getters[key](tbl) end
    end
    function mt.__newindex(_, key, value)
        if type(key) == 'number' then list[key] = value end
        return
    end
    function mt.__call()
        return ipairs(list)
    end
    return setmetatable(list, mt)
end

vim.list = List

local Dict

local dict_getters = {
    _type = function()
        return 'dict'
    end,
}

function Dict(tbl)
    local mt = {}
    function mt.__index(_, key)
        if dict_getters[key] then return dict_getters[key](tbl) end
    end
    function mt.__call()
        return pairs(tbl)
    end
    function mt.__len()
        return vim.tbl_count(tbl)
    end
    return setmetatable(tbl, mt)
end

vim.dict = Dict

vim.beep = function()
    io.write('\a')
end
