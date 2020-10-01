local fn = vim.fn

if fn.has('nvim') == 1 then
    local api = vim.api

    vim.command = api.nvim_command
    vim.eval = api.nvim_eval
    vim.line = api.nvim_get_current_line

    local buf_methods = {
        insert = function(self, newline, pos)
            api.nvim_buf_set_lines(self.number, pos or -1, pos or -1, false, {newline})
        end,
        isvalid = function(self)
            return api.nvim_buf_is_valid(self.number)
        end,
        -- next = function(self)
        -- end,
        -- previous = function(self)
        -- end,
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
        type = function()
            return 'buffer'
        end,
    }

    local function Buffer(arg)
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
        -- Doesn't work?
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

    local win_methods = {
        isvalid = function(self)
            return api.nvim_win_is_valid(self.number)
        end,
        -- next = function(self)
        -- end,
        -- previous = function(self)
        -- end,
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
        type = function()
            return 'window'
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

    local function Window(arg)
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
        if object.type then return object.type end
        return type(object)
    end
end
