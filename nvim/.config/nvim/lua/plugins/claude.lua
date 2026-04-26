-- ============================================================
--  plugins/claude.lua — coder/claudecode.nvim
--  Integration with Claude Code CLI (claude command)
-- ============================================================

return {
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		lazy = false,

		opts = {
			port = nil,
			terminal_cmd = "vsplit",
			auto_sync_file = true,
			diff_opts = {
				auto_close_on_accept = true,
				show_diff_stats = true,
				vertical_split = true,
			},
		},

		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude" },
			{ "<leader>an", "<cmd>ClaudeCodeNew<CR>", desc = "New Claude session" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiff<CR>", desc = "Diff with Claude" },
			{ "<leader>ax", "<cmd>ClaudeCodeStop<CR>", desc = "Stop Claude" },
		},
	},
}
