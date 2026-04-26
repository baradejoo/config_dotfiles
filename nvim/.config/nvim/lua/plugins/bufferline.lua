-- ============================================================
--  plugins/bufferline.lua — akosmenkov/bufferline.nvim
--  Tab bar at the top showing open buffers
-- ============================================================

return {
	"akinsho/bufferline.nvim",
	version = "*",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },

	opts = {
		options = {
			mode = "buffers",
			separator_style = "slant",
			show_buffer_close_icons = true,
			show_close_icon = false,
			color_icons = true,
			diagnostics = "nvim_lsp", -- show LSP error counts per tab
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			offsets = {
				{
					filetype = "neo-tree",
					text = "File Explorer",
					highlight = "Directory",
					separator = true,
				},
			},
		},
	},

	keys = {
		{ "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
		{ "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned buffers" },
	},
}
