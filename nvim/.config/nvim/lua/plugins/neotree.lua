-- ============================================================
--  plugins/neotree.lua — nvim-neo-tree/neo-tree.nvim
--  File tree panel on the left side
-- ============================================================

local _width = nil

local function default_width()
	return math.max(20, math.floor(vim.o.columns * 0.2))
end

local function get_width()
	if _width == nil then
		_width = default_width()
	end
	return _width
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	keys = {
		{ "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
		{ "<leader>o", "<cmd>Neotree focus<CR>", desc = "Focus file tree" },
		{ "<leader>ge", "<cmd>Neotree git_status toggle<CR>", desc = "Git status tree" },
	},

	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",

			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
				},
				modified = { symbol = "●" },
				git_status = {
					symbols = {
						added = "✚",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
			},

			window = {
				position = "left",
				width = get_width,
				mappings = {
					["<space>"] = "none",
					["<"] = function(state)
						local win = vim.api.nvim_get_current_win()
						_width = math.max(10, vim.api.nvim_win_get_width(win) - 5)
						state.window.width = _width
						vim.api.nvim_win_set_width(win, _width)
					end,
					[">"] = function(state)
						local win = vim.api.nvim_get_current_win()
						_width = vim.api.nvim_win_get_width(win) + 5
						state.window.width = _width
						vim.api.nvim_win_set_width(win, _width)
					end,
					["="] = function(state)
						_width = default_width()
						state.window.width = _width
						vim.api.nvim_win_set_width(vim.api.nvim_get_current_win(), _width)
					end,
					["l"] = "open",
					["h"] = "close_node",
					["H"] = "toggle_hidden",
					["<CR>"] = "open",
					["v"] = "open_vsplit",
					["s"] = "open_split",
					["t"] = "open_tabnew",
					["R"] = "refresh",
					["a"] = "add",
					["d"] = "delete",
					["r"] = "rename",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["?"] = "show_help",
				},
			},

			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "open_current",
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {
						"__pycache__",
						".git",
						"node_modules",
						".pytest_cache",
						".mypy_cache",
						".ruff_cache",
					},
				},
			},

			git_status = {
				window = { position = "float" },
			},
		})

		-- Track mouse / <C-w>< / <C-w>> resize so neo-tree doesn't reset it
		vim.api.nvim_create_autocmd("WinResized", {
			desc = "Persist neo-tree width after manual resize",
			callback = function()
				for _, win in ipairs(vim.v.event.windows or {}) do
					if vim.api.nvim_win_is_valid(win)
						and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
					then
						_width = vim.api.nvim_win_get_width(win)
					end
				end
			end,
		})
	end,
}
