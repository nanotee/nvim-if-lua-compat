require('if_lua_compat')
local b = vim.buffer({})
-- b()
-- print(#b)
-- print(b[154])
-- print(b.name)
-- print(b.fname)
-- print(b.number)
-- b:insert('hello', 127)
-- print(b:isvalid())
-- print(b:next())
-- print(b:previous())
-- b.type = 'window'
-- print(vim.type(b))

local w = vim.window()
-- w()
-- print(w.buffer.name)
-- print(w.line)
-- w.line = 92
-- print(w.col)
-- w.col = 3
-- print(w.width)
-- w.width = 60
-- print(w.height)
-- w.height = 20
-- w:next()
-- w:previous()
-- print(w:isvalid())
-- w.type = 'buffer'
-- print(vim.type(w))


-- print(vim.type(3))
-- print(vim.type({}))
-- print(vim.type('str'))
