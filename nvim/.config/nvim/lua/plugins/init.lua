-- ============================================================
--  plugins/init.lua — lazy.nvim bootstrap + plugin list
-- ============================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- ── Colorscheme ─────────────────────────────────────────
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			opts = { style = "night", transparent = false },
			config = function(_, opts)
				require("tokyonight").setup(opts)
				vim.cmd.colorscheme("tokyonight")
			end,
		},

		-- ── Snacks — swiss-army knife ────────────────────────────
		{ import = "plugins.snacks" },

		-- ── Bufferline — tab bar at the top ───────────────────────
		{ import = "plugins.bufferline" },

		-- ── Treesitter ───────────────────────────────────────────
		{ import = "plugins.treesitter" },

		-- ── LSP ──────────────────────────────────────────────────
		{ import = "plugins.lsp" },

		-- ── Completion ───────────────────────────────────────────
		{ import = "plugins.completion" },

		-- ── Formatting ──────────────────────────────────────────
		{ import = "plugins.formatting" },

		-- ── C++ linting (nvim-lint — optional second layer) ───────
		-- clangd already runs clang-tidy inline via --clang-tidy flag.
		-- Uncomment below only if you want standalone clang-tidy + cppcheck on save.
		-- { import = "plugins.linting" },

		-- ── Claude ───────────────────────────────────────────────
		{ import = "plugins.claude" },

		-- ── File tree ─────────────────────────────────────────────
		{ import = "plugins.neotree" },

		-- ── Markdown preview ──────────────────────────────────────
		{ import = "plugins.markdown" },

		-- ── Misc utilities ───────────────────────────────────────
		{ import = "plugins.misc" },
	},

	-- Lazy UI
	ui = { border = "rounded" },

	-- Do not check for updates on startup
	checker = { enabled = true, notify = false },

	-- Performance
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
