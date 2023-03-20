local nls = require("null-ls")
local builtins = nls.builtins

local function has_exec(filename)
    return function()
        return vim.fn.executable(filename) == 1
    end
end

local async_formatting = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.lsp.buf_request(
        bufnr,
        "textDocument/formatting",
        vim.lsp.util.make_formatting_params({}),
        function(err, res, ctx)
            if err then
                local err_msg = type(err) == "string" and err or err.message
                -- you can modify the log message / level (or ignore it completely)
                vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
                return
            end

            -- don't apply results if buffer is unloaded or has been modified
            if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
                return
            end

            if res then
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent noautocmd update")
                end)
            end
        end
    )
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                async_formatting(bufnr)
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
