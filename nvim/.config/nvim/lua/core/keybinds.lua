local util = require('core.util')

vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

-- Vim managment

-- Recording mode is so fucking stupid
vim.api.nvim_set_keymap('n', 'q', '<Nop>', {})
-- Open vimrc (lua files) for editing
util.nnoremap('<leader>vrc', ':tabedit ~/.dotfiles/nvim/.config/nvim/lua/<cr>')
-- Source vimrc (lua files)
util.nmap('<leader>src', ':luafile ~/.dotfiles/nvim/.config/nvim/init.lua<cr>')

--- Buffer lifecycle

-- Quit current buffer
util.nnoremap('<leader>q', ':q<cr>')
-- Quit all open buffers 
util.nnoremap('<leader>qa', ':q<cr>')
-- Force quit (kill) current buffer
util.nnoremap('<leader>k', ':q!<cr>')
-- Force quit (kill) all open buffers
util.nnoremap('<leader>ka', ':xa!<cr>')
-- Write current buffer
util.nnoremap('<leader>fs', ':update<cr>')
-- Write all open buffers
util.nnoremap('<leader>fsa', ':wall<cr>')
-- Write and quit current buffer 
util.nnoremap('<leader>wq', ':update<cr>:q<cr>')
-- Write and quit all open buffers
util.nnoremap('<leader>wqa', ':wall<cr>:xa<cr>')
-- Force write and quit current buffer
util.nnoremap('<leader>wk', ':update!<cr>:q!<cr>')
-- Force write and quit all open buffers
util.nnoremap('<leader>wka', ':update!<cr>:xa!<cr>')
-- Quit buffer below
util.nnoremap('<leader>qwj', '<c-w>j:q<cr>')

-- Buffer navigation

-- Open nerdtree buffer
util.nnoremap('<leader>fo', ':NERDTreeToggle<cr>')

-- Telescope navigation
util.nnoremap('<leader>ff', ':Telescope find_files<cr>')
util.nnoremap('<leader>fg', ':Telescope live_grep<cr>')
util.nnoremap('<leader>fb', ':Telescope buffers<cr>')

-- Pane navigation
util.nnoremap('<leader>wh', '<c-w>h') -- Left
util.nnoremap('<leader>wH', '<c-w>H') -- Move left
util.nnoremap('<leader>wl', '<c-w>l') -- Right
util.nnoremap('<leader>wL', '<c-w>L') -- Move right
util.nnoremap('<leader>wk', '<c-w>k') -- Up
util.nnoremap('<leader>wK', '<c-w>K') -- Move left
util.nnoremap('<leader>wj', '<c-w>j') -- Down
util.nnoremap('<leader>wJ', '<c-w>J') -- Move left

--- Misc.

-- Clear current highlight group
util.nnoremap('<leader>nh', ':noh<cr>')

-- Open Trouble pane
util.nnoremap('<leader>xx', ':TroubleToggle<cr>')

-- Open Symbols outline pane
util.nnoremap('<leader>ss', ':SymbolsOutline<cr>')
