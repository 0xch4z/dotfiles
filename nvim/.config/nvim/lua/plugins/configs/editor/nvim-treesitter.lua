local tsconf = require("nvim-treesitter.configs")

tsconf.setup({
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "go",
        "gomod",
        "javascript",
        "json",
        "lua",
        "python",
        "ruby",
        "toml",
        "yaml",
        "tsx",
        "vue",
        "typescript",
        "rust",
        "hcl",
        "make",
        "help",
    },
    autotag = {
        enabled = true,
    },
    ident = {
        enable = true,
    },
    highlight = {
        enable = true,
        disable = function(ft, bufnr)
            if vim.tbl_contains({ "vim" }, ft) then
                return true
            end

            local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
            return ok and is_large_file
        end,
        additional_vim_regex_highlighting = { "c", "cpp" },
    },
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]["] = "@function.outer",
                ["]m"] = "@class.outer",
            },
            goto_next_end = {
                ["]]"] = "@function.outer",
                ["]M"] = "@class.outer",
            },
            goto_previous_start = {
                ["[["] = "@function.outer",
                ["[m"] = "@class.outer",
            },
            goto_previous_end = {
                ["[]"] = "@function.outer",
                ["[M"] = "@class.outer",
            },
        },
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 2000,
    },
    matchup = { enable = true },
})
