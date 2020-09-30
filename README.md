# nvim-if-lua-compat

An `if_lua` compatibility layer for Neovim (WIP, needs testing)

## Goals

Maintain some amount compatibility with the existing Vim interface for Lua (see also: [neovim/neovim#12537](https://github.com/neovim/neovim/issues/12537)). Some features might not be possible to implement (AFAIK Neovim doesn't have a Blob data type)

## Progress

- [ ] `vim.list()`
    - [ ] `#l`
    - [ ] `l[k]`
    - [ ] `l()`
    - [ ] `table.insert(l, newitem)`
    - [ ] `table.insert(l, position, newitem)`
    - [ ] `table.remove(l, position)`
    - [ ] `l:add(item)`
    - [ ] `l:insert(item[, pos])`
- [ ] `vim.dict()`
    - [ ] `#d`
    - [ ] `d.key` or `d['key']`
    - [ ] `d()`
- [ ] `vim.blob()`
    - [ ] `#b`
    - [ ] `b[k]`
    - [ ] `b:add(bytes)`
- [x] `vim.funcref()` (in Neovim core)
    - [ ] `#f`
    - [x] `f(...)`
- [x] `vim.buffer()`
    - [x] `b()`
    - [ ] `#b` (does LuaJIT/Lua 5.1 have a `__len` metamethod?)
    - [x] `b[k]`
    - [x] `b.name`
    - [x] `b.fname`
    - [x] `b.number`
    - [x] `b:insert(newline[, pos])`
    - [ ] `b:next()`
    - [ ] `b:previous()`
    - [x] `b:isvalid()`
- [x] `vim.window()`
    - [x] `w()`
    - [x] `w.buffer`
    - [x] `w.line` (get and set)
    - [x] `w.col` (get and set)
    - [x] `w.width` (get and set)
    - [x] `w.height` (get and set)
    - [ ] `w:next()`
    - [ ] `w:previous()`
    - [x] `w:isvalid()`
- [ ] `vim.type()`
- [x] `vim.command()` (alias to `vim.api.nvim_command()`)
- [x] `vim.eval()` (alias to `vim.api.nvim_eval()`)
- [x] `vim.line()` (alias to `vim.api.nvim_get_current_line()`)
- [ ] `vim.beep()`
- [x] `vim.open()`
- [x] `vim.call()` (in Neovim core)
- [x] `vim.fn()` (in Neovim core)
