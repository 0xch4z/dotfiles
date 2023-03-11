local editor = {}

local util = require("plugins.util")
local load = util.load

-- Makes jk fast
editor["rainbowhxch/accelerated-jk.nvim"] = {
    lazy = true,
    event = "VeryLazy",
    config = load("plugins.configs.editor.accelerated-jk"),
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
    event = { "BufReadPost" },
    dependencies = {
        { "abecodes/tabout.nvim" },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        { "mrjones2014/nvim-ts-rainbow" },
        { "JoosepAlviste/nvim-ts-context-commentstring" },
        { "mfussenegger/nvim-treehopper" },
        { "andymass/vim-matchup" },
        {
            "windwp/nvim-ts-autotag",
            config = load("plugins.configs.editor.autotag"),
        },
        {
            "NvChad/nvim-colorizer.lua",
            config = load("plugins.configs.editor.colorizer"),
        },
        {
            "abecodes/tabout.nvim",
            config = load("plugins.configs.editor.tabout"),
        },
    },
    config = load("plugins.configs.editor.nvim-treesitter"),
}

-- Trailing whitespace shows up red
editor["ntpeters/vim-better-whitespace"] = {
    lazy = true,
    event = "InsertEnter",
}

return editor
