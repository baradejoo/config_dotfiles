-- ============================================================
--  plugins/claude.lua — coder/claudecode.nvim
--  Integracja z Claude Code CLI (claude command)
-- ============================================================

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    -- Load at startup — needed to listen for selections
    lazy = false,

    ---@type ClaudeCodeConfig
    opts = {
      -- Port for claude code CLI connection (random by default)
      -- Leave nil to let the plugin pick a free port
      port = nil,

      -- Where to show the Claude terminal
      -- "vsplit" | "split" | "float" | "tab"
      terminal_cmd = "vsplit",

      -- Automatically track active file in Claude
      auto_sync_file = true,

      -- Open diff when Claude proposes changes
      diff_opts = {
        auto_close_on_accept = true,
        show_diff_stats      = true,
        vertical_split       = true,
      },
    },

    keys = {
      -- Open / toggle Claude Code
      { "<leader>ac",  "<cmd>ClaudeCode<CR>",           desc = "Toggle Claude Code" },
      -- Send selected text to Claude
      { "<leader>as",  "<cmd>ClaudeCodeSend<CR>",       mode = "v", desc = "Send selection to Claude" },
      -- Open with new task (clears history)
      { "<leader>an",  "<cmd>ClaudeCodeNew<CR>",        desc = "New Claude session" },
      -- Diff review
      { "<leader>ad",  "<cmd>ClaudeCodeDiff<CR>",       desc = "Diff with Claude" },
      -- Zatrzymaj Claude
      { "<leader>ax",  "<cmd>ClaudeCodeStop<CR>",       desc = "Stop Claude" },
    },
  },
}
