local ssplits = require("smart-splits")

ssplits.setup({
    ignored_filetypes = {
        "nofile",
        "quickfix",
        "prompt",
    },
    ignored_buftypes = {
        "NvimTree",
    },
    default_amount = 3,
    resize_mode = {
        quit_key = "<ESC>",
        resize_keys = { "h", "j", "k", "l" },
        silent = false,
    },
})
