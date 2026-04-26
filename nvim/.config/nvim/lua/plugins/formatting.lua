-- ============================================================
--  plugins/formatting.lua — conform.nvim
--  ruff (Python) + clang-format (C/C++)
--
--  Version pinning matches .pre-commit-config.yaml:
--    clang-format  →  v22  (same as Mason clangd@22.1.0)
--    ruff          →  0.15.10
--
--  Binary resolution: Mason path → $PATH (pixi/system fallback)
-- ============================================================

local function mason_bin(name)
  local p = vim.fn.stdpath("data") .. "/mason/bin/" .. name
  if vim.uv.fs_stat(p) then return p end
  return name
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd   = { "ConformInfo" },

  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_fallback = true }) end,
      desc = "Format file",
    },
  },

  opts = {
    formatters_by_ft = {
      c   = { "clang_format" },
      cpp = { "clang_format" },

      -- ruff_format + ruff_organize_imports replaces black + isort
      python = { "ruff_format", "ruff_organize_imports" },

      lua      = { "stylua" },
      json     = { "prettier" },
      yaml     = { "prettier" },
      markdown = { "prettier" },
    },

    format_on_save = function(bufnr)
      local ignore_ft = { "sql", "java" }
      if vim.tbl_contains(ignore_ft, vim.bo[bufnr].filetype) then return end
      if vim.api.nvim_buf_line_count(bufnr) > 5000 then return end
      return { timeout_ms = 1000, lsp_fallback = true }
    end,

    formatters = {
      -- clang-format v22 from Mason (matches pre-commit mirrors-clang-format v22.1.3)
      -- Finds .clang-format by walking up from the file — no --style needed
      clang_format = {
        command      = mason_bin("clang-format"),
        prepend_args = { "--fallback-style=llvm" },
      },

      -- ruff 0.15.10 from Mason (matches pre-commit ruff-precommit v0.15.10)
      -- Finds pyproject.toml / ruff.toml by walking up — no --config needed
      ruff_format = {
        command = mason_bin("ruff"),
      },

      -- ruff import sorting (replaces isort)
      ruff_organize_imports = {
        command = mason_bin("ruff"),
        args    = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
        stdin   = true,
      },
    },
  },
}
