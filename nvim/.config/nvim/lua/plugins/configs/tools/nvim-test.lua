require("nvim-test").setup({
    run = true,
    commands_create = true,
    filename_modifier = ":.",
    silent = false,
    term = "terminal",
    termOpts = {
        direction = "vertical",
        width = 96,
        height = 24,
        go_back = true,
        stopinsert = false,
        keep_one = true,
    },
    runners = { -- setup tests runners
        golang = "nvim-test.runners.go-test",
        haskell = "nvim-test.runners.hspec",
        javascriptreact = "nvim-test.runners.jest",
        javascript = "nvim-test.runners.jest",
        lua = "nvim-test.runners.busted",
        python = "nvim-test.runners.pytest",
        ruby = "nvim-test.runners.rspec",
        rust = "nvim-test.runners.cargo-test",
        typescript = "nvim-test.runners.jest",
        typescriptreact = "nvim-test.runners.jest",
    },
})

require("nvim-test.runners.go-test"):setup({})
