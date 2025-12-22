local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require('null-ls')

local opts = {
  sources = {
    --null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.formatting.clang_format,
  },
}
return opts
