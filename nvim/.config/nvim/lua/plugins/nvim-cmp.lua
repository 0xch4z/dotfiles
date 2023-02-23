local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')
lspkind.init({ preset = 'codicons' })

require('luasnip.loaders.from_vscode').lazy_load()

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {border = 'rounded'}
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {border = 'rounded'}
)

cmp.setup {
  preselect = true,
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },

  -- Load snippet support
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  formatting = {
    fields = {'kind', 'abbr'},
    format = function(entry, item)
      local cmp_entry = lspkind.cmp_format({
        mode = 'symbol',
        maxwidth = 50,
      })(entry, item)
      cmp_entry.kind = " " .. cmp_entry.kind .. " "
      return cmp_entry
    end
  },

  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },

  -- Load sources, see: https://github.com/topics/nvim-cmp
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'neorg' },
  },

  window = {
    documentation = cmp.config.window.bordered(),
    completion = {
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      col_offset = -3,
      side_padding = 0,
    }
  },
}
