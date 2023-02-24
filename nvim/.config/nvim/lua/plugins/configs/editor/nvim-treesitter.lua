local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.objc = {
    install_info = {
        url = "https://github.com/merico-dev/tree-sitter-objc",
        files = { "src/parser.c" },
        branch = "master",
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
    },
    filetype = "m",
}

local tsconf = require("nvim-treesitter.configs")

tsconf.setup({
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "go",
        "java",
        "javascript",
        "json",
        "lua",
        "python",
        "ruby",
        "toml",
        "solidity",
        "tsx",
        "typescript",
        "rust",
        "hcl",
        "org",
    },
    autotag = {
        enabled = true,
    },
    highlight = {
        enable = true,
        use_languagetree = true,
        custom_captures = {},
    },
    ident = {
        enable = true,
    },
    rainbow = {
        enable = true,
    },
})
