-- require('if_lua_compat')
local b = vim.buffer(105)
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
-- b._type = 'window'
-- print(vim.type(b))
-- print(b:next().name)
-- print(b:previous().name)

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
-- w._type = 'buffer'
-- print(vim.type(w))
-- print(w:next().height)
-- print(w:previous().line)


-- print(vim.type(3))
-- print(vim.type({}))
-- print(vim.type('str'))


local l = vim.list({1, test = 2, 3})
-- print(l[2])
-- print(l.test)
-- print(vim.type(l))
-- print(#l)
-- for v in l() do
--     print(v)
-- end
-- table.insert(l, 4)
-- table.insert(l, 2, 2)
-- table.insert(l, 2, 2)
-- print(l[2])
-- print(l[4])
-- print(vim.inspect(l))
-- table.remove(l, 4)
-- print(vim.inspect(l))
-- l.test = 'hello'
-- print(l.test)
-- l:add(4)
-- l:insert('test', 1)
-- l:insert('test2')
-- for k, v in l() do
--     print(k, v)
-- end

local d = vim.dict({1, test = 2, 3})
-- print(d.test)
-- print(d['test'])
-- print(d[1])
-- print(d[2])
-- for k, v in d() do
--     print(k, v)
-- end
-- print(#d)
-- print(vim.type(d))

-- vim.beep()
