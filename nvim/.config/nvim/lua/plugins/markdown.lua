-- ============================================================
--  plugins/markdown.lua — MeanderingProgrammer/render-markdown.nvim
--  Renders markdown directly in the buffer — no browser needed.
--  Headers, code blocks, tables, checkboxes, bullets all styled.
-- ============================================================

return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown", "md" },  -- only load for markdown files

  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = true,

    -- Heading styles with icons and colors
    heading = {
      enabled  = true,
      sign     = true,
      icons    = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },

    -- Code blocks — show language icon, style the block
    code = {
      enabled        = true,
      sign           = true,
      style          = "full",   -- "full" | "normal" | "language" | "none"
      border         = "thin",
      above          = "▄",
      below          = "▀",
    },

    -- Bullet points styled with icons
    bullet = {
      enabled = true,
      icons   = { "●", "○", "◆", "◇" },
    },

    -- Checkboxes
    checkbox = {
      enabled   = true,
      unchecked = { icon = "󰄱 " },
      checked   = { icon = "󰱒 " },
    },

    -- Tables
    pipe_table = {
      enabled = true,
      style   = "full",  -- "full" | "normal" | "none"
    },

    -- Horizontal rules
    dash = { enabled = true },

    -- Inline code
    inline_highlight = { enabled = true },
  },

  keys = {
    {
      "<leader>tm",
      function() require("render-markdown").toggle() end,
      ft   = "markdown",
      desc = "Toggle markdown render",
    },
  },
}
