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
  -- Packer
  use 'wbthomason/packer.nvim'
  -- File explorer
  use 'preservim/nerdtree'
  -- Tag viewer
  use 'preservim/tagbar'
  -- Treesitter interface
  use 'nvim-treesitter/nvim-treesitter'
  -- Color schemes
  use 'navarasu/onedark.nvim'
  -- LSP
  use 'neovim/nvim-lspconfig'
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'simrat39/symbols-outline.nvim'
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
  -- format
  use 'sbdchd/neoformat'

  -- misc
  use 'ntpeters/vim-better-whitespace'
  use 'kyazdani42/nvim-web-devicons'
  use 'folke/trouble.nvim'
  use 'tpope/vim-commentary'
  use 'nvim-lua/plenary.nvim'
  use 'neoclide/npm.nvim'
  use { 'Everblush/everblush.nvim', as = 'everblush' }

  -- end of plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
