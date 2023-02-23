local map = require('keymap.map')
local cmd = map.cmd

local mappings = {
  -- Config
  ['n|<leader>vrc'] = cmd('tabedit ~/.config/nvim/lua/'):noremap():desc('config: edit'),
  ['n|<leader>src'] = cmd('luafile ~/.config/nvim/init.lua'):noremap():desc('config: reload'),

  -- File + Buffer operations
  ['n|<leader>fo'] = cmd('Telescope file_browser'):noremap():desc('file: browse'),
  ['n|<leader>ff'] = cmd('Telescope find_files'):noremap():desc('file: find'),
  ['n|<leader>fg'] = cmd('Telescope live_grep'):noremap():desc('file: live grep'),
  ['n|<leader>bf'] = cmd('Telescope buffers'):noremap():desc('buffer: find'),

  -- Diagnostics
  ['n|<leader>de'] = cmd('TroubleToggle'):noremap():desc('diag: errors'),
  ['n|<leader>ds'] = cmd('SymbolsOutline'):noremap():desc('diag: symbol outline')
}

map.register_keys(mappings)
