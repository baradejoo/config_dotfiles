-- ============================================================
--  plugins/completion.lua — blink.cmp
-- ============================================================

return {
  "saghen/blink.cmp",
  event   = "InsertEnter",
  -- Pin to latest stable tag — avoid nightly builds
  version = "1.*",

  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset    = "default",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up",   "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"]  = { "accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },

    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },

    completion = {
      menu = {
        border     = "rounded",
        max_height = 15,
      },
      documentation = {
        auto_show          = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = { enabled = true },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    snippets = { preset = "default" },

    fuzzy = {
      use_frecency  = true,
      use_proximity = true,
    },

    signature = {
      enabled = true,
      window  = { border = "rounded" },
    },
  },
}
