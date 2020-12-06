local validate = vim.validate
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

local list_mt = {
    __index = list_methods,
    __newindex = function(list, key, value)
        if type(key) == 'number' then list[key] = value end
        return
    end,
    __call = function(list)
        local index = 0
        local function list_iter()
            local _, v = next(list, index)
            index = index + 1
            return v
        end
        return list_iter, list, nil
    end,
    type = 'list',
}

function List(tbl)
    validate {
        tbl = {tbl, 'table', true}
    }

    local list = {}
    if tbl then
        for _, v in ipairs(tbl) do
            table.insert(list, v)
        end
    end
    return setmetatable(list, list_mt)
end

return List
