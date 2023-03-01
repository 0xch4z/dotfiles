local nls = require("null-ls")
local builtins = nls.builtins

local function has_exec(filename)
    return function()
        return vim.fn.executable(filename) == 1
    end
end

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                lsp_formatting(bufnr)
            end,
        })
    end
end

nls.setup({
    debug = true,
    on_attach = on_attach,
    sources = {
        -- Go
        builtins.diagnostics.golangci_lint.with({
            runtime_condition = has_exec("golangci_lint"),
        }),
        builtins.formatting.gofmt.with({
            runtime_condition = has_exec("gofmt"),
        }),
        builtins.formatting.gofumpt.with({
            runtime_condition = has_exec("gofumpt"),
        }),
        builtins.formatting.goimports_reviser.with({
            runtime_condition = has_exec("goimports_reviser"),
        }),

        -- Shell
        builtins.diagnostics.shellcheck.with({
            runtime_condition = has_exec("shellcheck"),
        }),
        builtins.formatting.shfmt.with({
            runtime_condition = has_exec("shfmt"),
        }),
        builtins.formatting.shellharden.with({
            runtime_condition = has_exec("shellharden"),
        }),

        -- Rust
        builtins.formatting.rustfmt.with({
            runtime_condition = has_exec("rustfmt"),
        }),

        -- Lua
        builtins.diagnostics.luacheck.with({
            runtime_condition = has_exec("luacheck"),
        }),
        builtins.formatting.stylua.with({
            runtime_condition = has_exec("stylua"),
        }),
        builtins.formatting.stylua,

        -- YAML
        builtins.diagnostics.yamllint.with({
            runtime_condition = has_exec("yamllint"),
        }),
        builtins.formatting.yamlfmt.with({
            runtime_condition = has_exec("yamlfmt"),
        }),
        builtins.diagnostics.actionlint.with({
            runtime_condition = has_exec("actionlint"),
        }),

        -- Misc.
        builtins.diagnostics.editorconfig_checker.with({
            runtime_condition = has_exec("editorconfig_checker"),
        }),
    },
})
