local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Set indention to 2 spaces
augroup('setIndent2', { clear = true })
autocmd('Filetype', {
  group = 'setIndent2',
  pattern = {
    'yaml',
    'json',
    'lua',
    'javascript',
    'typescript',
  },
  command = 'setlocal shiftwidth=2 tabstop=2'
})

