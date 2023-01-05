local util = require('core.util')

-- init lazy.nvim

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)
vim.g.mapleader = ' '

function load(module)
  return function()
    require(module)
  end
end

require('lazy').setup({
  -- Appearance
  {
    'nyoom-engineering/oxocarbon.nvim',
    config = function()
      vim.cmd('colorscheme oxocarbon')
      vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
      vim.cmd('hi clear LineNr')
      vim.cmd('hi clear SignColumn')
    end
  },
  {
    'mhinz/vim-startify',
    config = load('plugins.vim-startify'),
  },

  -- Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    config = load('plugins.nvim-treesitter'),
  },
  {
    'ntpeters/vim-better-whitespace',
    event = 'InsertEnter',
  },

  -- Text-editing exp
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',  -- Comp. for LSP
      'neovim/nvim-lspconfig', -- Needs lspconfig configured first
      'hrsh7th/cmp-buffer',    -- Comp. for text in buffer
      'L3MON4D3/LuaSnip',      -- Comp. for snippets
      'onsails/lspkind.nvim'   -- Formatting for comp.
    },
    config = load('plugins.nvim-cmp'),
  },
  {
    'neovim/nvim-lspconfig',
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp"
    },
    config = load('plugins.nvim-lspconfig'),
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'InsertEnter',
    config = load('plugins.null-ls'),
  },
  {
    'sbdchd/neoformat',
    event = 'InsertEnter',
    config = load('plugins.neoformat'),
  },
  {
    'tpope/vim-commentary',
    event = 'VeryLazy',
  },

  -- Diagnostics/observability
  {
    'folke/trouble.nvim',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
    },
  },
  {
    'simrat39/symbols-outline.nvim',
    config = load('plugins.symbols-outline'),
  },

  -- Navigation
  {
    'lmburns/lf.nvim',
    config = load('plugins.lf'),
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    dependencies = 'nvim-lua/plenary.nvim',
    lazy = true,
  },

  -- Misc.
  {
    'nvim-lua/plenary.nvim',
    lazy = true,
  },
  {
    'nvim-orgmode/orgmode',
    dependencies = 'nvim-treesitter',
    config = load('plugins.orgmode')
  },

  -- Utilities
  {
    'akinsho/toggleterm.nvim',
    lazy = true,
  },
})
