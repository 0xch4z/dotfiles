local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- All filetypes not included in the autocmd below
-- will default to a shiftwidth and tabstop of 4.
augroup('setIndent2', { clear = true })
autocmd('Filetype', {
  group = 'setIndent2',
  pattern = {
    'yaml',
    'json',
    'lua',
    'javascript',
    'typescript',
    'html',
    'liquid',
    'ejs',
  },

  command = 'setlocal shiftwidth=2 tabstop=2',
})

-- Set formatter for JavaScript-ish code
augroup('jsishFmt', { clear = true })
autocmd('Filetype', {
  group = 'jsishFmt',
  pattern = {
    'javascript',
    'typescript',
  },

  command = "setlocal formatprg=prettier",
})

-- Format code on save
augroup('fmtOnSave', { clear = true })
autocmd('BufWritePre', {
  group = 'fmtOnSave',
  pattern = {
    -- JavaScript-ish
    '*.js',
    '*.ts',
    '*.jsx',
    '*.tsx',
  },

  command = 'Neoformat',
})

