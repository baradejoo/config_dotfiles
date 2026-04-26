# Neovim 0.12 Config

Custom config built on `lazy.nvim`. Designed for C++ (clangd) + Python (pyright + ruff),
with full control over every setting.

---

## Install Neovim 0.12

```bash
# Download binary
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz

# Check where your current nvim binary lives — it might be a symlink
ls -la $(which nvim)
# Example: ~/.local/bin/nvim -> ~/.local/opt/nvim/bin/nvim
# Your install root is ~/.local/opt/nvim/

# Replace the FULL installation (bin + lib + share must all match)
NVIM_ROOT=~/.local/opt/nvim   # adjust if your path differs

cp nvim-linux-x86_64/bin/nvim $NVIM_ROOT/bin/nvim
cp -r nvim-linux-x86_64/lib/* $NVIM_ROOT/lib/
cp -r nvim-linux-x86_64/share/* $NVIM_ROOT/share/

nvim --version  # should show 0.12.x
```

> **Important:** always replace `lib/` and `share/` together with the binary.
> The runtime in `share/nvim/runtime/` must match the binary version exactly —
> mismatched runtime causes errors like `attempt to call method 'set_timeout'`.

---

## Install config

```bash
# Backup old config
mv ~/.config/nvim         ~/.config/nvim.bak
mv ~/.local/share/nvim    ~/.local/share/nvim.bak
mv ~/.local/state/nvim    ~/.local/state/nvim.bak
mv ~/.cache/nvim          ~/.cache/nvim.bak

# Deploy via stow from dotfiles repo
cd ~/config_dotfiles
stow -R nvim

# Verify symlink
ls -la ~/.config/nvim
```

---

## Required external tools

### Must install via apt

```bash
# clangd + clang-format + clang-tidy must come from apt (or pixi).
# They need to match the Clang version used to build your project.
sudo apt install clangd clang-format clang-tidy

# cppcheck — not available in Mason registry
sudo apt install cppcheck

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Claude Code CLI (required for claudecode.nvim)
npm install -g @anthropic-ai/claude-code
```

### What Mason installs automatically

On first `nvim` launch (open a file, not just the dashboard), Mason auto-installs
these into `~/.local/share/nvim/mason/bin/` — no sudo needed:

| Tool | Purpose |
|------|---------|
| `clangd` | C++ LSP fallback (when not in pixi env) |
| `pyright` | Python LSP (type checking) |
| `ruff` | Python linter + formatter |
| `lua-language-server` | Lua LSP (for editing this config) |
| `stylua` | Lua formatter |

> Do **not** `pip install pyright` or `pip install ruff` globally —
> Mason manages these independently of your project venvs.

---

## First launch

```bash
# Open nvim WITH a file — Mason and LSP only load when a buffer is open
nvim ~/.config/nvim/init.lua
```

Then in order:

```
:Lazy sync          # install/update all plugins
:MasonToolsInstall  # install LSP servers and formatters
:TSUpdate           # download treesitter parsers
```

> `:MasonToolsInstall` fails with "Not an editor command" from the dashboard —
> it needs an actual file buffer to be active.

---

## Plugin overview

### Why these plugins and not others

| Plugin | Replaces | Reason |
|--------|----------|--------|
| `snacks.nvim` | telescope, neo-tree, noice, lazygit plugin, smooth scroll | One plugin instead of ~7, actively maintained by folke |
| `blink.cmp` | nvim-cmp | Written in Rust, significantly faster, better 0.12 integration |
| `conform.nvim` | null-ls, none-ls | Lightweight formatter runner, format-on-save |
| `neo-tree.nvim` | nvim-tree, oil | Stable v3, good git integration, offset support for bufferline |
| `bufferline.nvim` | — | Tab bar at the top showing open buffers with LSP error counts |
| `mini.ai` | nvim-treesitter-textobjects | Works with native 0.12 treesitter, no archived plugin dependency |
| `render-markdown.nvim` | — | Renders markdown in-buffer, no browser needed |
| `claudecode.nvim` | — | Claude AI integration directly in the editor |

### Why nvim-treesitter is NOT installed

`nvim-treesitter` is **archived** and explicitly states it does not support
Neovim 0.12. Installing it causes runtime errors:
- `attempt to call method 'set_timeout' (a nil value)`
- `attempt to call method 'range' (a nil value)`

Neovim 0.12 ships with treesitter built into core. Parsers are managed natively
via `:TSInstall <lang>` and `:TSUpdate`.

`nvim-treesitter-textobjects` also depends on nvim-treesitter and cannot be used.
Text objects (`af`, `if`, `ac`, `ic` etc.) are handled by `mini.ai` instead.

### Why clangd comes from apt, not Mason

clangd must match the Clang version used to compile your project. For ROS2/pixi
projects, open nvim inside `pixi shell` so clangd from pixi takes priority over
the Mason fallback.

**clangd binary resolution order:** pixi `$PATH` → Mason → system apt.

---

## Project structure and LSP

### C++ (clangd)

clangd walks **upward** from the opened file looking for:
- `compile_commands.json` — generated by cmake (`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`)
- `.clangd` — per-project clangd config
- Fallback: `CMakeLists.txt` or `.git`

For ROS2 / colcon + pixi:
```bash
pixi run build  # already has -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Symlink so clangd finds it when opening files under src/
ln -s ros2-build/compile_commands.json compile_commands.json
```

### Python (pyright + ruff)

Both walk **upward** from the opened file looking for:
- `pyrightconfig.json`
- `pyproject.toml` with `[tool.pyright]` / `[tool.ruff]` sections
- `setup.py`, `setup.cfg`


To reload LSP after config changes:
```
:lua vim.lsp.stop_client(vim.lsp.get_clients()); vim.cmd("e")
```

To check active LSP servers and their root directory:
```
:lua vim.print(vim.lsp.get_clients())
```

---

## Git workflow

### Lazygit (full UI)

```
<Space>gg   open lazygit (full TUI)
<Space>gf   lazygit log for current file
<Space>gl   lazygit repo log
<Space>gb   git branches picker
```

Inside lazygit:
- `space` — stage/unstage file
- `c` — commit
- `P` — push
- `p` — pull
- `b` — branches
- `?` — help / all keymaps

### Gitsigns (inline hunks)

| Key | Action |
|-----|--------|
| `]h` | Next hunk |
| `[h` | Prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage entire buffer |
| `<leader>hu` | Unstage hunk |
| `<leader>hp` | Preview hunk diff |
| `<leader>hb` | Blame current line |
| `<leader>hd` | Diff this file |

---

## Claude AI (claudecode.nvim)

Requires Claude Code CLI installed: `npm install -g @anthropic-ai/claude-code`

| Key | Action |
|-----|--------|
| `<Space>ac` | Toggle Claude Code panel |
| `<Space>as` | Send selected text to Claude (visual mode) |
| `<Space>an` | New Claude session (clears history) |
| `<Space>ad` | Review Claude's proposed diff |
| `<Space>ax` | Stop Claude |

**Workflow:**
1. `<Space>ac` — opens Claude in a vertical split
2. Type your request or use `<Space>as` to send selected code
3. Claude can read/write files directly in your project
4. When Claude proposes changes, `<Space>ad` shows a diff to review

---

## Key bindings reference

### Navigation

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>fb` | Buffer list |
| `<Space>fr` | Recent files |
| `<Space>fs` | LSP symbols in file |
| `<Space>fS` | LSP symbols in workspace |
| `<Space>/` | Grep in open buffers |
| `<S-l>` | Next buffer tab |
| `<S-h>` | Prev buffer tab |
| `<Space>bd` | Close buffer |
| `<Space>bp` | Pin buffer |
| `<C-h/j/k/l>` | Navigate between windows |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Implementations |
| `K` | Hover docs |
| `<C-k>` | Signature help |
| `<Space>ca` | Code action |
| `<Space>rn` | Rename symbol |
| `<Space>th` | Toggle inlay hints |
| `<Space>de` | Show diagnostic float |
| `[d` / `]d` | Prev / next diagnostic |
| `<Space>dl` | Diagnostic list |

### File tree (neo-tree)

| Key | Action |
|-----|--------|
| `<Space>e` | Toggle file tree |
| `<Space>o` | Focus file tree |
| `l` / `h` | Open / close node |
| `a` | New file (`name/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `H` | Toggle hidden files |
| `<Space>ge` | Git status tree |

### Editing

| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gc` + motion | Comment motion |
| `<Space>cf` | Format file |
| `ys<motion><char>` | Add surround |
| `ds<char>` | Delete surround |
| `cs<old><new>` | Change surround |
| `af` / `if` | Around/inside function (mini.ai) |
| `ac` / `ic` | Around/inside class |
| `aa` / `ia` | Around/inside argument |
| `J` / `K` | Move selected lines down/up (visual) |

### Markdown

| Key | Action |
|-----|--------|
| `<Space>tm` | Toggle markdown render |

---

## Updating tools

```
:Lazy sync        # update all plugins
:Lazy update      # same as sync
:Mason            # open Mason UI
U                 # (inside Mason) update all tools
:TSUpdate         # update treesitter parsers
```

To sync formatter versions with `.pre-commit-config.yaml` — check Mason UI
and update manually when you bump pre-commit revisions.

---

## New 0.12 LSP API used in this config

```lua
-- Old way (0.11 / nvim-lspconfig):
require("lspconfig").clangd.setup({ ... })

-- New way (0.12 native):
vim.lsp.config("clangd", { ... })
vim.lsp.enable("clangd")
```

`nvim-lspconfig` is kept as a dependency for utilities but LSP configuration
uses the native 0.12 API. This means `:LspRestart` and `:LspInfo` (lspconfig
commands) do not work — use the native API instead:

```lua
-- Check active LSP clients and their root_dir
:lua vim.print(vim.lsp.get_clients())

-- Restart LSP for current buffer
:lua vim.lsp.stop_client(vim.lsp.get_clients()); vim.cmd("e")
```
