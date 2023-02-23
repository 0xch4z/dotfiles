local apperance = {}

local util = require('plugins.util')
local load = util.load

apperance['nyoom-engineering/oxocarbon.nvim'] = {
  config = load('plugins.oxocarbon')
}

apperance['mhinz/vim-startify'] = {
  config = load('plugins.vim-startify')
}

return apperance
