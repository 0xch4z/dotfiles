require("lspsaga").setup({
    rename = {
        quit = "<C-c>",
        mark = "x",
        confirm = "<CR>",
        exec = "<CR>",
        in_select = true,
    },
    outline = {
        win_position = "right",
        win_with = "_sagaoutline",
        win_width = 30,
        auto_preview = false,
        auto_refresh = true,
        auto_close = true,
        keys = {
            jump = "<CR>",
            expand_collapse = "u",
            quit = "q",
        },
    },
})
