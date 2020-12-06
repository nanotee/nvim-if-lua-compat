local api = vim.api
local Buffer = require('if_lua_compat.buffer')

local Window

local win_methods = {
    isvalid = function(self)
        return api.nvim_win_is_valid(self.number)
    end,
    next = function(self)
        local winnr = getmetatable(self).winnr
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
        local winnr = getmetatable(self).winnr
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

    mt.type = 'window'
    mt.winnr = winnr

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

return Window
