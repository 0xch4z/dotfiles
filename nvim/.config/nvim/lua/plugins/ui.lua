local ui = {}

local util = require('plugins.util')
local load = util.load

ui['nyoom-engineering/oxocarbon.nvim'] = {
  config = load('plugins.oxocarbon')
}

ui['mhinz/vim-startify'] = {
  config = load('plugins.vim-startify')
}

ui['lewis6991/gitsigns.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = load('plugins.configs.ui.gitsigns'),
}

return ui