-- ============================================================
--  plugins/neotree.lua — nvim-neo-tree/neo-tree.nvim
--  File tree panel on the left side
-- ============================================================

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch  = "v3.x",
  lazy    = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  keys = {
    { "<leader>e",  "<cmd>Neotree toggle<CR>",               desc = "Toggle file tree" },
    { "<leader>o",  "<cmd>Neotree focus<CR>",                desc = "Focus file tree" },
    { "<leader>ge", "<cmd>Neotree git_status toggle<CR>",    desc = "Git status tree" },
  },

  opts = {
    close_if_last_window = true,
    popup_border_style   = "rounded",

    default_component_configs = {
      indent = {
        indent_size         = 2,
        padding             = 1,
        with_markers        = true,
        indent_marker       = "│",
        last_indent_marker  = "└",
        highlight           = "NeoTreeIndentMarker",
        with_expanders      = true,
        expander_collapsed  = "",
        expander_expanded   = "",
      },
      icon = {
        folder_closed = "",
        folder_open   = "",
        folder_empty  = "󰜌",
      },
      modified = { symbol = "●" },
      git_status = {
        symbols = {
          added     = "✚",
          modified  = "",
          deleted   = "✖",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
    },

    window = {
      position = "left",
      width    = 35,
      mappings = {
        ["<space>"] = "none",   -- nie konfliktuj z <leader>
        ["l"]       = "open",
        ["h"]       = "close_node",
        ["H"]       = "toggle_hidden",
        ["<CR>"]    = "open",
        ["v"]       = "open_vsplit",
        ["s"]       = "open_split",
        ["t"]       = "open_tabnew",
        ["R"]       = "refresh",
        ["a"]       = "add",
        ["d"]       = "delete",
        ["r"]       = "rename",
        ["c"]       = "copy",
        ["m"]       = "move",
        ["q"]       = "close_window",
        ["?"]       = "show_help",
      },
    },

    filesystem = {
      -- Automatically reveal current file in tree
      follow_current_file = {
        enabled             = true,
        leave_dirs_open     = false,
      },
      -- Use git to track modified files
      use_libuv_file_watcher = true,
      hijack_netrw_behavior  = "open_current",
      filtered_items = {
        visible        = false,
        hide_dotfiles  = false,   -- show .env, .gitignore etc.
        hide_gitignored = true,
        hide_by_name   = {
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
  },
}
