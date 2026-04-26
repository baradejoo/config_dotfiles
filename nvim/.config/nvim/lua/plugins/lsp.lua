-- ============================================================
--  plugins/lsp.lua
--  Uses new 0.12 API: vim.lsp.config() + vim.lsp.enable()
--  nvim-lspconfig kept as a dependency for root_dir utilities
--
--  Tool versions are pinned to match .pre-commit-config.yaml:
--    clang-format / clangd  →  v22  (mirrors-clang-format rev: v22.1.3)
--    ruff                   →  0.15.10 (ruff-pre-commit rev: v0.15.10)
--    pyright                →  latest stable (not in pre-commit)
-- ============================================================

-- ── Helper: resolve binary path ──────────────────────────────────────────
-- Priority: pixi env (if active) → Mason → system PATH
-- This means:
--   - Inside `pixi shell`: picks up pixi's clangd automatically
--   - Outside pixi: falls back to Mason-installed version
--   - Mason not installed: falls back to whatever is on $PATH
local function mason_bin(name)
	local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. name
	if vim.uv.fs_stat(mason_path) then
		return mason_path
	end
	return name -- fall back to $PATH (pixi env or system)
end

-- For clangd specifically: prefer $PATH first (pixi), then Mason
-- so that when inside pixi shell the project-matched version wins
local function clangd_cmd()
	local path_clangd = vim.fn.exepath("clangd")
	if path_clangd ~= "" then
		return path_clangd -- pixi or system clangd
	end
	return vim.fn.stdpath("data") .. "/mason/bin/clangd" -- Mason fallback
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = { ui = { border = "rounded" } },
			},
			{ "mason-org/mason-lspconfig.nvim", opts = {} },

			-- mason-tool-installer: declarative, versioned, auto-installs on startup
			-- Versions pinned to match .pre-commit-config.yaml
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = {
						-- ── C/C++ ──────────────────────────────────────────────────
						-- clangd: Mason installs latest available, pixi env takes priority when active
						-- This is the baseline fallback — pixi env takes priority when active
						"clangd",

						-- ── Python ─────────────────────────────────────────────────
						-- ruff: Mason installs latest available
						"ruff",
						-- pyright: not in pre-commit, use latest stable
						"pyright",

						-- ── Lua ────────────────────────────────────────────────────
						"lua-language-server",
						"stylua",

						-- ── C++ static analysis ────────────────────────────────────
						-- "cppcheck",
					},
					-- Don't auto-update — you control versions explicitly above
					-- Run :MasonToolsUpdate when you want to bump
					auto_update = false,
					run_on_start = true,
				},
			},
		},

		config = function()
			-- ── Diagnostic icons ─────────────────────────────────────────────
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 2,
					format = function(diag)
						local max = 120
						if #diag.message > max then
							return diag.message:sub(1, max) .. "…"
						end
						return diag.message
					end,
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- ── Keymaps on LspAttach ──────────────────────────────────────────
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", function()
						Snacks.picker.lsp_definitions()
					end, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", function()
						Snacks.picker.lsp_references()
					end, "References")
					map("gi", function()
						Snacks.picker.lsp_implementations()
					end, "Implementations")
					map("gt", vim.lsp.buf.type_definition, "Type definition")
					map("K", vim.lsp.buf.hover, "Hover docs")
					map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>fs", function()
						Snacks.picker.lsp_symbols()
					end, "Symbols in file")
					map("<leader>fS", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "Symbols in workspace")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method("textDocument/inlayHint") then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle inlay hints")
					end
				end,
			})

			-- ================================================================
			--  LSP configs — new 0.12 API
			-- ================================================================

			-- ── clangd ───────────────────────────────────────────────────────
			-- cmd resolution order: pixi $PATH → Mason@22 → system
			vim.lsp.config("clangd", {
				cmd = {
					clangd_cmd(),
					"--background-index",
					"--clang-tidy", -- uses .clang-tidy found by walking up from file
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
					"--offset-encoding=utf-16",
				},
				root_markers = {
					"compile_commands.json",
					"compile_flags.txt",
					".clangd",
					"CMakeLists.txt",
					".git",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				capabilities = capabilities,
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			})
			vim.lsp.enable("clangd")

			-- ── pyright ──────────────────────────────────────────────────────
			vim.lsp.config("pyright", {
				cmd = { mason_bin("pyright-langserver"), "--stdio" },
				root_markers = {
					"pyrightconfig.json",
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					".git",
				},
				filetypes = { "python" },
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							typeCheckingMode = "standard",
						},
					},
				},
			})
			vim.lsp.enable("pyright")

			-- ── lua_ls ───────────────────────────────────────────────────────
			vim.lsp.config("lua_ls", {
				cmd = { mason_bin("lua-language-server") },
				root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
				filetypes = { "lua" },
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						diagnostics = { globals = { "vim", "Snacks" } },
						telemetry = { enable = false },
					},
				},
			})
			vim.lsp.enable("lua_ls")
		end,
	},
}
