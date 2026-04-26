-- ============================================================
--  keymaps.lua
-- ============================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = function(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { silent = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- ── General ──────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<C-s>", "<cmd>w<CR>")
map("i", "<C-s>", "<Esc><cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })

-- ── Window navigation ─────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- ── Buffers ───────────────────────────────────────────────────
-- <S-l> and <S-h> are handled by bufferline (see plugins/bufferline.lua)
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- ── Move lines ────────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- ── Clipboard ─────────────────────────────────────────────────
map("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- ── Diagnostics ───────────────────────────────────────────────
-- <leader>e is taken by neo-tree (toggle file tree)
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ── LSP keymaps are set in LspAttach (see plugins/lsp.lua) ───

-- ── Snacks keymaps are set in plugins/snacks.lua ─────────────
-- <leader>ff  find files
-- <leader>fg  live grep
-- <leader>fb  buffers
-- <leader>gg  lazygit
-- <leader>gf  lazygit file log
