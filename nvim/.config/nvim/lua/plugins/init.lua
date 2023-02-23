-- Set up lazy.nvim, install if needed
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

local function flatten_plugins(...)
  local flattened = {}
  local tables = {...}

  for _, plugins in ipairs(tables) do
    for plugin, config in pairs(plugins) do
			flattened[#flattened+1] = vim.tbl_extend('force', { plugin }, config)
    end
  end

  return flattened
end

local plugins = flatten_plugins(
  require('plugins.apperance'),
  require('plugins.completion'),
  require('plugins.diagnostics'),
  require('plugins.editor')
)

require('lazy').setup(plugins)
