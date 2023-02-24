-- Set leader keys
vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

-- Register key bindings
require("keymap.ui")
require("keymap.tools")
require("keymap.editor")
