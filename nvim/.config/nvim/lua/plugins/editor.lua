local editor = {}

local util = require("plugins.util")
local load = util.load

-- Makes jk fast
editor["rainbowhxch/accelerated-jk.nvim"] = {
    lazy = true,
    event = "VeryLazy",
}

-- autopairs syntax
editor["altermo/ultimate-autopair.nvim"] = {
    lazy = true,
    event = "InsertEnter",
    config = load("plugins.configs.editor.ultimate-autopair"),
}

-- Utility for commenting/uncommenting
editor["tpope/vim-commentary"] = {
    lazy = true,
    event = { "CursorHold", "CursorHoldI" },
}

-- Treesitter
editor["nvim-treesitter/nvim-treesitter"] = {
    lazy = true,
    event = { "CursorHold", "CursorHoldI" },
    dependencies = {
        { "abecodes/tabout.nvim" },
    },
    config = load("plugins.nvim-treesitter"),
}

-- Trailing whitespace shows up red
editor["ntpeters/vim-better-whitespace"] = {
    lazy = true,
    event = "InsertEnter",
}

return editor
