local tools = {}
local util = require("plugins.util")
local load = util.load

tools["folke/which-key.nvim"] = {
    lazy = true,
    event = "VeryLazy",
}

tools["LeonHeidelbach/trailblazer.nvim"] = {
    lazy = true,
    config = load("plugins.configs.tools.trailblazer"),
    event = "VeryLazy",
}

tools["nvim-telescope/telescope.nvim"] = {
    tag = "0.1.0",
    dependencies = {
        { "nvim-tree/nvim-web-devicons" },
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        {
            "nvim-telescope/telescope-frecency.nvim",
            dependencies = {
                { "kkharji/sqlite.lua" },
            },
        },
        { "debugloop/telescope-undo.nvim" },
        { "nvim-lua/popup.nvim" },
    },
    config = load("plugins.configs.tools.telescope"),
}

tools["folke/trouble.nvim"] = {
    lazy = true,
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    config = load("plugins.configs.tools.trouble"),
}

tools["ibhagwan/smartyank.nvim"] = {
    lazy = true,
    event = "BufReadPost",
}

tools["klen/nvim-test"] = {
    lazy = true,
    config = load("plugins.configs.tools.nvim-test"),
    cmd = { "TestEdit", "TestSuite", "TestFile", "TestPrevious", "TestInfo", "TestNearest" },
    dependencies = {
        { "nvim-treesitter/nvim-treesitter" },
    },
}

tools["tamago324/lir.nvim"] = {
    config = load("plugins.configs.tools.lir"),
}

tools["phaazon/mind.nvim"] = {
    config = load("plugins.configs.tools.mind"),
}

tools["ellisonleao/glow.nvim"] = {
    config = load("plugins.configs.tools.glow"),
    cmd = { "Glow" },
}

tools["mrjones2014/smart-splits.nvim"] = {
    config = load("plugins.configs.tools.smart-splits"),
}

return tools
