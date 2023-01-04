local lsp_status_ok, lspconfig = pcall(require, 'lspconfig')
if not lsp_status_ok then
  error("lspconfig is not available")
end

local cmp_status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not cmp_status_ok then
  error("cmp_nvim_lsp is not available")
end

local protocol = require('vim.lsp.protocol')
local bo = vim.bo

if (os.getenv("NVIM_DEBUG") == "1") then
  vim.lsp.set_log_level("debug")
end

-- See: `:help vim.diagnostic.config`
vim.diagnostic.config({
  update_in_insert = false,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
	},
})

-- See: https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
local capabilities = cmp_nvim_lsp.default_capabilities()

capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  },
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function bmap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function bset(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  bset('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  bmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  bmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  bmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  bmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  bmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  bmap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  bmap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  bmap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  bmap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  bmap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  bmap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  bmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  bmap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  bmap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  bmap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  bmap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  bmap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end


-- See: https://github.com/neovim/nvim-lspconfig/issues/320
local root_dir = function()
  return vim.fn.getcwd()
end

-- all language servers: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- local servers = { 'bashls', 'clangd', 'tsserver', 'gopls', 'rls', 'yamlls', 'jsonls', 'terraformls' }
local lsp_configs = {
  bashls = {
    ft = {'bash', 'sh'},
  },
  sourcekit = {
    ft = {'swift'},
  },
  clangd = {
    ft = {'c', 'cc', 'cpp', 'mm', 'm'},
  },
  gopls = {
    ft = {'go', 'gowork', 'mod', 'sum'},
  },
  rust_analyzer = {
    ft = {'rust'}
  }
}


-- Describes whether the current buffer has initialized the LSP for it's
-- Filetype.
local current_buffer_started = false

for lsp, config in pairs(lsp_configs) do
  -- Setup the language server
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    filetypes = config.ft,
    root_dir = root_dir,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }

  -- The LSP is lazy loaded until InsertEnter is emitted on a buffer. This
  -- means that on first emit for a buffer, the proper LSP is not automatically
  -- loaded via Filetype.
  -- To remedy this, check if the lsp we're configuring should be turned on for
  -- the current buffer.
  if not current_buffer_started then
    for _, ft in ipairs(config.ft) do
      if ft == bo.filetype then
        vim.cmd(':LspStart ' .. lsp .. '<CR>')
        current_buffer_started = true
      end
    end
  end
end
