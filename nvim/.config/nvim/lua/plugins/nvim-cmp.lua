local has_cmp, cmp = pcall(require, 'cmp')

local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
  return
end

local luasnip_status_ok, luasnip = pcall(require, 'luasnip')
if not luasnip_status_ok then
  return
end

if has_cmp then
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
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
        local menu_icon = {
          nvim_lsp = 'λ',
          luasnip = '⋗',
          buffer = 'Ω',
          path = '🖫',
        }

        item.menu = menu_icon[entry.source.name]
        return item
      end,
    },

    mapping = {
      ['<Up>'] = cmp.mapping.select_prev_item(),
      ['<Down>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
    },

    -- Load sources, see: https://github.com/topics/nvim-cmp
    sources = {
      { name = 'nvim_lsp', keyword_length = 2 },
      { name = 'nvim_lsp_signature_help' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    },

    window = {
      documentation = cmp.config.window.bordered(),
    },
  }
end
