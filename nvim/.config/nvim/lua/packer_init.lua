-- All packer plugins are declared here; file reloads on save

local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  -- install packer
  packer_bootstrap = fn.system({
    'git',
    'clone',
    '--depth=1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

-- quick autocmd that reloads neovim whenever you save this file.
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

-- Install plugins
return packer.startup(function(use)
  config = { max_jobs = 10 }

  -- Packer
  use 'wbthomason/packer.nvim'

  -- File explorer
  use 'preservim/nerdtree'

  -- Treesitter interface
  use 'nvim-treesitter/nvim-treesitter'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'

  -- Diagnostics
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- Observability
  use 'simrat39/symbols-outline.nvim'
  use 'ntpeters/vim-better-whitespace'

  -- Autocomplete
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'saadparwaiz1/cmp_luasnip',
    },
  }

  -- Start screen
  use 'mhinz/vim-startify'

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = 'nvim-lua/plenary.nvim',
  }

  -- Code formatting
  use 'sbdchd/neoformat'

  -- Visual stuff
  use 'kyazdani42/nvim-web-devicons'
  use({
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
        vim.cmd('colorscheme rose-pine')
    end
  })

  -- Utility
  use({
    "akinsho/toggleterm.nvim", tag = '*', config = function()
      require("toggleterm").setup()
    end
  })

  -- Misc.
  use 'tpope/vim-commentary'
  use 'nvim-lua/plenary.nvim'

  -- End of plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
