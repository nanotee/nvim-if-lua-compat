local api = vim.api
local fn = vim.fn
local Buffer = require('if_lua_compat.buffer')

local valid_fname_types = {
    number = true,
    string = true,
}

--- @param fname ?any
--- @return Buffer
local function vim_open(fname)
    fname = valid_fname_types[type(fname)] and tostring(fname) or nil

    local bufnr = fn.bufadd(fname or '')
    api.nvim_buf_set_option(bufnr, 'buflisted', true)

    return Buffer(bufnr)
end

--- @param object any
--- @return string
local function vim_type(object)
    local mt = getmetatable(object) or {}
    return mt.type or type(object)
end

local function vim_beep()
    local belloff = api.nvim_get_option('belloff')
    if belloff:match('all') or belloff:match('lang') then return end
    io.write('\a')
end

return {
    open = vim_open,
    type = vim_type,
    beep = vim_beep,
}
