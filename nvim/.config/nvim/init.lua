-- Load packer plugins
require('packer_init')

-- Load lua modules
require('core.keybinds')
require('core.config')
require('core.autocmd')

-- Plugin specific modules
require('plugins.nvim-lspconfig')
require('plugins.nvim-cmp')
require('plugins.nvim-treesitter')
require('plugins.neoformat')
require('plugins.null-ls')
require('plugins.startify')
require('plugins.telescope')
require('plugins.symbols-outline')
