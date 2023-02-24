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
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-frecency.nvim", dependencies = {
            { "kkharji/sqlite.lua" },
        } },
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
    event = "BufReadPost",
    config = load("plugins.configs.tools.nvim-test"),
}

return tools
