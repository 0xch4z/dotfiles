local tools = {}
local util = require('plugins.util')
local load = util.load

tools['simtra39/symbols-outline.nvim'] = {
  config = load('plugins.symbols-outline'),
}

tools['folke/which-key.nvim'] = {
	lazy = true,
	event = 'VeryLazy',
}

tools['nvim-telescope/telescope.nvim'] = {
  tag = '0.1.0',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		{ 'nvim-telescope/telescope-frecency.nvim', dependencies = {
			{ 'kkharji/sqlite.lua' },
		} },
  },
  config = load('plugins.telescope'),
}

tools['folke/trouble.nvim'] = {
	lazy = true,
	cmd = { 'Trouble', 'TroubleToggle', 'TroubleRefresh' },
}

tools['ibhagwan/smartyank.nvim'] = {
	lazy = true,
	event = 'BufReadPost',
}

return tools
