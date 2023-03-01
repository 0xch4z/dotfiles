local lang = {}
local util = require("plugins.util")
local load = util.load

lang["saecki/crates.nvim"] = {
    event = { "InsertEnter Cargo.toml" },
    config = load("plugins.configs.lang.crates"),
}

return lang
