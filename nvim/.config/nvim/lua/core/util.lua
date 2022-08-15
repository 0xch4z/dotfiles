local M = {}

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
