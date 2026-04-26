-- ============================================================
--  plugins/linting.lua — mfussenegger/nvim-lint
--
--  Optional second layer on top of clangd's built-in clang-tidy.
--  Runs linters on save independently of LSP indexing state.
--
--  To enable: uncomment `{ import = "plugins.linting" }` in plugins/init.lua
-- ============================================================

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufWritePost" },

  config = function()
    local lint = require("lint")

    -- ── Linters per filetype ──────────────────────────────────
    lint.linters_by_ft = {
      -- clang-tidy: walks up from the file to find .clang-tidy
      -- cppcheck: broad static analysis, catches different issues than clang-tidy
      cpp = { "clangtidy", "cppcheck" },
      c   = { "clangtidy", "cppcheck" },
    }

    -- ── clang-tidy config ─────────────────────────────────────
    -- By default nvim-lint runs: clang-tidy <file>
    -- clang-tidy finds .clang-tidy by walking up from the file,
    -- same root-discovery logic as clangd — works with your multi-service layout.
    lint.linters.clangtidy = vim.tbl_deep_extend("force", lint.linters.clangtidy, {
      args = {
        -- Pass compile_commands.json so clang-tidy understands includes/flags.
        -- The '-p' flag accepts a directory containing compile_commands.json.
        -- We resolve it dynamically per-buffer below.
        "--use-color=0",
      },
      -- Override the args factory to inject -p dynamically
      -- (finds compile_commands.json in the LSP root)
      condition = function(ctx)
        -- Only run if a compile_commands.json is reachable
        local root = vim.fs.root(ctx.filename, { "compile_commands.json", ".clangd", ".git" })
        if root then
          -- Inject -p <root> so clang-tidy picks up the right compilation database
          lint.linters.clangtidy.args = {
            "-p", root,
            "--use-color=0",
          }
          return true
        end
        -- No compile_commands found — skip (clangd already covers this case)
        return false
      end,
    })

    -- ── cppcheck config ───────────────────────────────────────
    lint.linters.cppcheck = vim.tbl_deep_extend("force", lint.linters.cppcheck, {
      args = {
        "--enable=all",
        "--suppress=missingIncludeSystem",  -- ignore missing system headers
        "--suppress=unmatchedSuppression",
        "--inline-suppr",                   -- allow //cppcheck-suppress in code
        "--language=c++",
        "--std=c++17",
        "--template=gcc",                   -- output format nvim-lint understands
      },
    })

    -- ── Trigger linting ───────────────────────────────────────
    local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group    = lint_augroup,
      callback = function()
        -- Don't lint huge files
        if vim.api.nvim_buf_line_count(0) > 10000 then return end
        lint.try_lint()
      end,
    })

    -- Manual trigger
    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
      vim.notify("Linting " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
    end, { desc = "Run linters" })
  end,
}
