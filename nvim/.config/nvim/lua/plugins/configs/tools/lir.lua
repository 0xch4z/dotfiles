local actions = require("lir.actions")
local clipboard_actions = require("lir.clipboard.actions")

require("lir").setup({
    show_hidden_files = false,
    ignore = {
        ".DS_Store",
        ".git",
        "node_modules",
        "vendor",
    },
    devicons = {
        enable = true,
        highlight_dirname = true,
    },
    mappings = {
        ["l"] = actions.edit,
        ["s"] = actions.split,
        ["v"] = actions.vsplit,

        ["h"] = actions.up,
        ["q"] = actions.quit,

        ["f"] = actions.mkdir,
        ["n"] = actions.newfile,
        ["r"] = actions.rename,
        ["@"] = actions.cd,
        ["y"] = actions.yank_path,
        ["."] = actions.toggle_show_hidden,
        ["d"] = actions.delete,

        ["c"] = clipboard_actions.copy,
        ["x"] = clipboard_actions.cut,
        ["p"] = clipboard_actions.paste,
    },
    float = {
        winblend = 0,
        curdir_window = {
            enable = true,
            highlight_dirname = true,
        },
    },
    hide_cursor = true,
})

require("nvim-web-devicons").set_icon({
    lir_folder_icon = {
        icon = "",
        color = "#7ebae4",
        name = "LirFolderNode",
    },
})
