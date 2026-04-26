-- ============================================================
--  options.lua
-- ============================================================

local o = vim.opt

-- General
o.number         = true
o.relativenumber = false
o.signcolumn     = "yes"
o.cursorline     = true
o.scrolloff      = 8
o.sidescrolloff  = 8

-- Indentation
o.tabstop        = 4
o.shiftwidth     = 4
o.softtabstop    = 4
o.expandtab      = true
o.smartindent    = true

-- Wyszukiwanie
o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = false
o.incsearch      = true

-- UI
o.termguicolors  = true
o.showmode       = false        -- statusline pokazuje tryb
o.wrap           = false
o.splitright     = true
o.splitbelow     = true
o.laststatus     = 3            -- global statusline (0.12)
o.cmdheight      = 0            -- ukryj cmdline gdy nieaktywna (0.12)

-- Files
o.undofile       = true
o.swapfile       = false
o.backup         = false

-- Completion (natywne 0.12)
o.completeopt    = "menuone,noinsert,noselect,popup"
o.pumheight      = 10

-- Fold (treesitter)
o.foldmethod     = "expr"
o.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel      = 99           -- open by default
o.foldlevelstart = 99

-- Misc
o.updatetime     = 200
o.timeoutlen     = 300
o.clipboard      = "unnamedplus"
o.mouse          = "a"
o.breakindent    = true
o.list           = true
o.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }
