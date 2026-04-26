-- ============================================================
--  plugins/misc.lua — miscellaneous plugins
-- ============================================================

return {

  -- ── Statusline ─────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme              = "tokyonight",
        globalstatus       = true,
        disabled_filetypes = { statusline = { "dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1 },
        },
        lualine_x = {
          {
            function()
              local ok, conform = pcall(require, "conform")
              if not ok then return "" end
              local formatters = conform.list_formatters()
              if #formatters == 0 then return "" end
              return "󰉼 " .. table.concat(vim.tbl_map(function(f) return f.name end, formatters), ", ")
            end,
            color = { fg = "#7aa2f7" },
          },
          "encoding",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- ── Gitsigns ─────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]h", function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
          else gs.nav_hunk("next") end
        end, { desc = "Next hunk" })
        map("n", "[h", function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
          else gs.nav_hunk("prev") end
        end, { desc = "Prev hunk" })

        map("n", "<leader>hs", gs.stage_hunk,      { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk,      { desc = "Reset hunk" })
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
        map("n", "<leader>hS", gs.stage_buffer,    { desc = "Stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Unstage hunk" })
        map("n", "<leader>hp", gs.preview_hunk,    { desc = "Preview hunk" })
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
        map("n", "<leader>hd", gs.diffthis,        { desc = "Diff this" })

        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Hunk text obj" })
      end,
    },
  },

  -- ── Autopairs ────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {
      check_ts         = true,
      disable_filetype = { "TelescopePrompt", "vim" },
    },
  },

  -- ── Surround ─────────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
    -- ys<motion><char>  add surround
    -- ds<char>          delete surround
    -- cs<old><new>      change surround
  },

  -- ── mini.ai — enhanced text objects ──────────────────────
  -- Replaces nvim-treesitter-textobjects, works with nvim 0.12
  -- a"/i" a'/i' a`/i` a(/i( a[/i[ a{/i{ a</i< built-in
  -- af/if (function), ac/ic (class), aa/ia (argument)
  {
    "echasnovski/mini.ai",
    version = "*",
    event   = "VeryLazy",
    opts    = { n_lines = 500 },
  },

  -- ── TODO comments ────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = { signs = true },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft", "<cmd>TodoPicker<CR>",                               desc = "TODOs in project" },
    },
  },

  -- ── Which-key ─────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      preset = "helix",
      spec   = {
        { "<leader>a", group = "AI / Claude" },
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>f", group = "Find / Picker" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git hunks" },
        { "<leader>r", group = "Rename / Refactor" },
        { "<leader>t", group = "Toggle" },
      },
    },
  },

  -- ── Comment.nvim ─────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts  = {},
    -- gcc  toggle line comment
    -- gbc  toggle block comment
    -- gc<motion>, gb<motion>
  },

  -- ── nvim-web-devicons ─────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── plenary (dependency for many plugins) ─────────────────
  { "nvim-lua/plenary.nvim", lazy = true },
}
