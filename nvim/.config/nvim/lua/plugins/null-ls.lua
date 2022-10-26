local nls = require('null-ls')

nls.setup({
  sources = {
    nls.builtins.diagnostics.eslint_d,
  },
})

