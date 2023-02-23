local map = require('keymap.map')
local cmd = map.cmd

local mappings = {
  -- Buffer operations
  ['n|<leader>fs']  = cmd('update'):noremap():desc('buffer: save'),
  ['n|<leader>fsa'] = cmd('wall'):noremap():desc('buffer: save all'),
}

map.register_keys(mappings)
