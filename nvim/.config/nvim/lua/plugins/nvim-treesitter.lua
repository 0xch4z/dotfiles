local tsconf = require('nvim-treesitter.configs')

tsconf.setup({
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'go',
    'java',
    'javascript',
    'json',
    'lua',
    'python',
    'ruby',
    'toml',
    'solidity',
    'norg',
    'tsx',
    'typescript',
    'rust',
    'hcl'
  },
  autotag = {
    enabled = true
  },
  highlight = {
    enable = true,
    use_languagetree = true,
    custom_captures = {}
  },
  ident = {
    enable = true
  },
  rainbow = {
    enable = true
  },
})

