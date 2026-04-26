-- ============================================================
--  plugins/treesitter.lua
--
--  Returns empty table intentionally.
--
--  Neovim 0.12 ships with treesitter built into core — the
--  nvim-treesitter plugin is archived and explicitly states it
--  does NOT support Neovim 0.12. Installing it causes errors:
--    "attempt to call method 'set_timeout' (a nil value)"
--    "attempt to call method 'range' (a nil value)"
--
--  nvim-treesitter-textobjects also depends on nvim-treesitter
--  and therefore cannot be used either. Text objects (af, if,
--  ac, ic, aa, ia) are handled by mini.ai instead (see misc.lua).
--
--  Parsers are managed natively — use :TSInstall <lang> or
--  :TSUpdate to install/update them.
-- ============================================================

return {}
