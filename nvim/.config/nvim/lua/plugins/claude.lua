-- ============================================================
--  plugins/claude.lua — coder/claudecode.nvim
--  Integration with Claude Code CLI (claude command)
-- ============================================================

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    config = true,

    opts = {
      terminal_cmd = vim.fn.expand("~/.local/bin/claude"),
      auto_start   = true,
      log_level    = "info",

      terminal = {
        split_side             = "right",
        split_width_percentage = 0.35,
        provider               = "snacks",
        auto_close             = true,
      },

      diff_opts = {
        layout           = "vertical",
        open_in_new_tab  = false,
        keep_terminal_focus = false,
      },
    },

    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Send selection to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Add file from tree", ft = { "neo-tree" } },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
    },
  },
}
