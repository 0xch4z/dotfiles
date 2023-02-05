local M = {}

local function _printi(lvl, ...)
  local indent = string.rep(' ', lvl * 2)
  print(indent, ...)
end

-- prints a table
function M.log_table(table, lvl)
  lvl = lvl or 0

  if lvl == 0 then
    -- we're at the beginning of a print
    _printi(0, '{')
    lvl = lvl + 1
  end

  -- visit attributes
  for k, v in pairs(table) do
    local kind = type(v)

    if kind == 'table' then
      _printi(lvl, k, '= {')
      M.log_table(v, lvl+1)
    elseif kind == 'thread' then
      _printi(lvl, k, '=', '<thread>')
    elseif kind == 'function' then
      _printi(lvl, k, '=', '<function>')
    elseif kind == 'userdata' then
      _printi(lvl, k, '=', 'userdata')
    else
      _printi(lvl, k, '=', v)
    end
  end

  -- step down
  lvl = lvl - 1
  _printi(lvl, '}')
end

-- helpers for:
-- vim.api.nvim_set_keymap(mode, key, result, options)

-- normal mode, no remap
function M.nnoremap(from, to)
	return vim.api.nvim_set_keymap("n", from, to, { noremap = true, silent = true })
end

-- normal mode, with remap
function M.nmap(from, to)
	return vim.api.nvim_set_keymap("n", from, to, { noremap = false, silent = true })
end

-- set opts
function M.opt(o, v, scopes)
	scopes = scopes or {vim.o}
	for _, s in ipairs(scopes) do s[o] = v end
end

return M
