# config_dotfiles

Dotfiles for zsh, tmux, Neovim and Alacritty, managed with [GNU Stow](https://www.gnu.org/software/stow/).
They work on macOS (Apple Silicon and Intel) and Linux.

## What's inside

| Package         | Links to                    | Notes                                                    |
|-----------------|-----------------------------|----------------------------------------------------------|
| `zsh`           | `~/.zshrc`                  | completion, fzf, fzf-tab, zoxide, history, lazy-loaded nvm |
| `powerlevel10k` | `~/.powerlevel10k`, `~/.p10k.zsh` | prompt theme (submodule) and its config            |
| `oh-my-zsh`     | `~/.oh-my-zsh/custom/plugins` | only the plugins (submodules): autosuggestions, syntax-highlighting, completions, fzf-tab. oh-my-zsh itself is **not** used |
| `tmux`          | `~/.tmux.conf`, `~/.tmux`   | backtick prefix, vi copy mode, system clipboard, sessions survive reboots (resurrect + continuum, submodules) |
| `nvim`          | `~/.config/nvim`            | lazy.nvim + Mason, needs Neovim **0.12+**, see [its README](nvim/.config/nvim/README.md) |
| `alacritty`     | `~/.config/alacritty`       | theme `hardhacker` (submodule), LiterationMono Nerd Font, starts inside tmux session `main` |
| `git`           | `~/.config/git/config`      | delta as pager; your `~/.gitconfig` (name, email) is left alone and still wins |

## Install

```bash
git clone --recurse-submodules git@github.com:baradejoo/config_dotfiles.git ~/Programming/config_dotfiles
cd ~/Programming/config_dotfiles
./install.sh
```

`install.sh`:

1. installs dependencies: on macOS via Homebrew and the [`Brewfile`](Brewfile); on Linux via apt, pacman or dnf,
   plus a Neovim release build if the distro ships one older than 0.12, and the Nerd Font,
2. fetches the submodules,
3. moves any existing files that would conflict (e.g. `~/.zshrc`) to `~/.dotfiles-backup/<date>/`,
4. links every package into `~` with `stow`,
5. installs the Neovim plugins pinned in `lazy-lock.json`.

It is safe to run again. Use `./install.sh --no-deps` to only (re)link the configs.

### Manual install

```bash
brew bundle                 # macOS; on Linux install the packages from install.sh
git submodule update --init --recursive
stow zsh powerlevel10k oh-my-zsh tmux nvim alacritty
```

`.stowrc` sets `--target=~`, so the repo doesn't have to live directly in your home directory.
Run `stow` from the repo root. To remove a package's links, use `stow -D <package>`.

### Notes

- **Alacritty on macOS**: the Homebrew cask was disabled on 2026-09-01 because the app isn't notarized.
  `install.sh` downloads the `.dmg` from [GitHub releases](https://github.com/alacritty/alacritty/releases)
  and removes the quarantine flag. If you install it by hand and macOS refuses to open it, run:
  `xattr -dr com.apple.quarantine /Applications/Alacritty.app`
- **Don't run the oh-my-zsh installer.** It overwrites `~/.zshrc` and breaks the stow link.
- Machine-specific settings (conda, work tokens, etc.) don't belong in the repo. Add them to `~/.zprofile`
  or `~/.zshenv`.
- **Tools used from Neovim** must be on your PATH:
  - `lazygit` for `<leader>gg` / `<leader>gf` / `<leader>gl` (snacks.nvim). Installed by `install.sh`.
  - Claude Code CLI, see below.
- **Claude Code CLI**: the `claudecode.nvim` plugin (`<leader>a…` bindings) runs `claude` from your PATH.
  `install.sh` doesn't install it, so install it yourself (the official installer puts it in `~/.local/bin`,
  which `.zshrc` adds to PATH):
  ```bash
  curl -fsSL https://claude.ai/install.sh | bash
  ```
- On first start Neovim's Mason installs the LSP servers (clangd, pyright, ruff, lua-ls). This needs
  `node`, `python`, `curl`, `unzip` and a C compiler (Xcode Command Line Tools / `build-essential`).

## Key bindings

### zsh

| Keys / command    | Action                                               |
|-------------------|------------------------------------------------------|
| <kbd>Tab</kbd>    | completion in an fzf window (fzf-tab), type to filter |
| <kbd>Ctrl+R</kbd> | fuzzy search in history                              |
| <kbd>Ctrl+T</kbd> | insert a file path (with `bat` preview)              |
| <kbd>Alt+C</kbd>  | cd into a subdirectory (with tree preview)           |
| <kbd>↑</kbd> / <kbd>↓</kbd> | history filtered by what's already typed   |
| `z <part>`        | jump to a frequently used directory (zoxide), `zi` to pick with fzf |
| `cat`, `ls`       | aliased to `bat` and `eza` when installed            |

### tmux (prefix: <kbd>`</kbd> backtick, press twice to type one)

| Keys              | Action                               |
|-------------------|--------------------------------------|
| `` ` `` `\|` or `\` | split left / right                 |
| `` ` `` `-`       | split top / bottom                   |
| `` ` `` `w a s q` | move to pane left / down / right / up |
| `` ` `` arrows    | resize pane                          |
| `` ` `` `,` `.`   | previous / next window               |
| `` ` `` `<` `>`   | move window left / right             |
| `` ` `` `n` / `N` | rename window / session              |
| `` ` `` `x` / `X` | kill pane / window                   |
| `` ` `` `v V h H t` | layouts: even-h, main-v, even-v, main-h, tiled |
| `` ` `` `r`       | reload config                        |
| `` ` `` `[`, then `v` … `y` | copy mode: select, copy to system clipboard |
| `` ` `` `d`       | detach (session keeps running, `tmux a` to come back) |
| `` ` `` `Ctrl+s` / `Ctrl+r` | save / restore sessions now (tmux-resurrect) |

Sessions are also saved automatically every 15 minutes and restored when tmux starts after
a reboot (tmux-continuum). Windows, panes, working directories and pane contents come back;
running programs (servers, ssh) have to be started again. Saves live in `~/.local/share/tmux/resurrect`.

Alacritty opens straight into the tmux session `main` (attaching if it already exists).
To get a plain shell instead, remove the `[terminal.shell]` block from `alacritty.toml`.

`w`, `s` and `q` replace tmux's defaults (window tree, session tree, `display-panes`).
Use `` ` `` `(` / `)` to switch sessions instead.

### Neovim

Leader is <kbd>Space</kbd>. See [`lua/keymaps.lua`](nvim/.config/nvim/lua/keymaps.lua).
