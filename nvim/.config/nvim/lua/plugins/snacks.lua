-- ============================================================
--  plugins/snacks.lua — folke/snacks.nvim
--  Replaces: telescope, neo-tree/oil, noice, lazygit integration
-- ============================================================

return {
  "folke/snacks.nvim",
  priority = 900,
  lazy     = false,

  ---@type snacks.Config
  opts = {

    -- ── Picker (telescope replacement) ──────────────────────
    picker = {
      enabled = true,
      -- Uses native fzf when available
      matcher = { frecency = true },
      win = {
        input = {
          keys = {
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-k>"] = { "list_up",   mode = { "i", "n" } },
          },
        },
      },
    },

    -- ── Notifikacje ──────────────────────────────────────────
    notifier = {
      enabled  = true,
      timeout  = 3000,
      top_down = false,
    },

    -- ── Statuscolumn ─────────────────────────────────────────
    statuscolumn = { enabled = true },

    -- ── Indent guides ────────────────────────────────────────
    indent = {
      enabled = true,
      animate = { enabled = false },  -- disable animations for performance
    },

    -- ── Scroll (smooth) ──────────────────────────────────────
    scroll = { enabled = true },

    -- ── Lazygit ──────────────────────────────────────────────
    lazygit = {
      enabled = true,
      -- otwiera w floating window
      win = { style = "lazygit" },
    },

    -- ── Dashboard ────────────────────────────────────────────
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys",    gap = 1, padding = 1 },
        { section = "startup" },
      },
    },

    -- ── Bigfile — disable heavy plugins on large files ──
    bigfile = { enabled = true },

    -- ── Bufdelete — clean buffer closing ─────────────────
    bufdelete = { enabled = true },

    -- ── Quickfile — faster startup for first file ───────────
    quickfile = { enabled = true },

    -- ── Words — highlight word under cursor ─────────────────
    words = { enabled = true },

  },

  keys = {
    -- Picker
    { "<leader>ff", function() Snacks.picker.files() end,                    desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end,                     desc = "Live grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end,                  desc = "Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end,                   desc = "Recent files" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end,              desc = "LSP symbols" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end,              desc = "Diagnostics" },
    { "<leader>fc", function() Snacks.picker.command_history() end,          desc = "Command history" },
    { "<leader>/",  function() Snacks.picker.grep_buffers() end,             desc = "Grep in buffers" },
    { "<leader>:",  function() Snacks.picker.commands() end,                 desc = "Commands" },

    -- Git
    { "<leader>gg", function() Snacks.lazygit() end,                         desc = "Lazygit" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end,                desc = "Lazygit: file log" },
    { "<leader>gl", function() Snacks.lazygit.log() end,                     desc = "Lazygit: repo log" },
    { "<leader>gb", function() Snacks.picker.git_branches() end,             desc = "Git branches" },

    -- Misc
    { "<leader>n",  function() Snacks.notifier.show_history() end,           desc = "Notification history" },
    { "<leader>bd", function() Snacks.bufdelete() end,                       desc = "Delete buffer" },
    { "<leader>.",  function() Snacks.scratch() end,                         desc = "Scratch buffer" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end,          desc = "Next word occurrence" },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end,         desc = "Prev word occurrence" },
  },
}
