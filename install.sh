#!/usr/bin/env bash
# Bootstrap these dotfiles on macOS or Linux.
#
#   ./install.sh            install dependencies, back up conflicting files, stow everything
#   ./install.sh --no-deps  skip dependency installation, only link the configs
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh powerlevel10k oh-my-zsh tmux nvim alacritty)
NVIM_MIN="0.12"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
INSTALL_DEPS=1

for arg in "$@"; do
  case "$arg" in
    --no-deps) INSTALL_DEPS=0 ;;
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"
ARCH="$(uname -m)"

# ---------------------------------------------------------------- macOS

install_alacritty_macos() {
  if [[ -d /Applications/Alacritty.app ]]; then
    return
  fi
  info "Downloading Alacritty from GitHub releases (Homebrew cask is disabled)"
  local url tmp mnt
  url="$(curl -fsSL https://api.github.com/repos/alacritty/alacritty/releases/latest |
    grep -o '"browser_download_url": *"[^"]*\.dmg"' | head -1 | cut -d'"' -f4)"
  if [[ -z "$url" ]]; then
    warn "could not find Alacritty .dmg, install it manually: https://github.com/alacritty/alacritty/releases"
    return
  fi
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/Alacritty.dmg" "$url"
  mnt="$(hdiutil attach -nobrowse -readonly "$tmp/Alacritty.dmg" | grep -o '/Volumes/.*' | head -1)"
  cp -R "$mnt/Alacritty.app" /Applications/
  hdiutil detach -quiet "$mnt"
  rm -rf "$tmp"
  # the app is not notarized, so Gatekeeper would refuse to open it
  xattr -dr com.apple.quarantine /Applications/Alacritty.app || true
}

install_deps_macos() {
  if ! xcode-select -p >/dev/null 2>&1; then
    info "Installing Xcode Command Line Tools (re-run this script when it finishes)"
    xcode-select --install
    exit 1
  fi
  if ! have brew; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
  info "Installing packages from Brewfile"
  brew bundle --file="$DOTFILES/Brewfile"
  install_alacritty_macos
}

# ---------------------------------------------------------------- Linux

install_nerd_font_linux() {
  local dir="$HOME/.local/share/fonts/LiberationMono"
  [[ -d "$dir" ]] && return
  info "Installing LiberationMono Nerd Font"
  mkdir -p "$dir"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/LiberationMono.tar.xz |
    tar -xJ -C "$dir"
  if have fc-cache; then fc-cache -f "$dir" >/dev/null; fi
}

version_ge() { [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]; }

install_nvim_linux() {
  local current=""
  have nvim && current="$(nvim --version | head -1 | grep -o '[0-9][0-9.]*' | head -1)"
  if [[ -n "$current" ]] && version_ge "$current" "$NVIM_MIN"; then
    return
  fi
  info "Installing Neovim release build (distro version ${current:-none} < $NVIM_MIN)"
  local arch
  case "$ARCH" in
    x86_64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "no Neovim release for $ARCH, install >= $NVIM_MIN manually"; return ;;
  esac
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/nvim-linux-$arch"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" |
    tar -xz -C "$HOME/.local/opt"
  ln -sf "$HOME/.local/opt/nvim-linux-$arch/bin/nvim" "$HOME/.local/bin/nvim"
}

install_deps_linux() {
  local sudo="" pkg
  [[ $EUID -ne 0 ]] && sudo="sudo"
  if have apt-get; then
    info "Installing packages with apt"
    $sudo apt-get update
    $sudo apt-get install -y git stow zsh tmux curl unzip xz-utils build-essential \
      ripgrep fd-find fzf nodejs npm python3 python3-venv fontconfig
    for pkg in eza alacritty; do
      $sudo apt-get install -y "$pkg" || warn "$pkg not available in apt, install it manually"
    done
    # Debian/Ubuntu ship fd as `fdfind`
    if have fdfind && ! have fd; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
  elif have pacman; then
    info "Installing packages with pacman"
    $sudo pacman -S --needed --noconfirm git stow zsh tmux curl unzip base-devel \
      ripgrep fd fzf eza nodejs npm python neovim alacritty fontconfig
  elif have dnf; then
    info "Installing packages with dnf"
    $sudo dnf install -y git stow zsh tmux curl unzip gcc make \
      ripgrep fd-find fzf nodejs npm python3 fontconfig
    for pkg in eza alacritty; do
      $sudo dnf install -y "$pkg" || warn "$pkg not available in dnf, install it manually"
    done
  else
    warn "unsupported package manager, install dependencies manually (see README)"
  fi
  install_nvim_linux
  install_nerd_font_linux
}

# ---------------------------------------------------------------- linking

# Move files that would block stow into $BACKUP_DIR (keeping their paths).
backup_conflicts() {
  local pkg rel target
  for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r rel; do
      target="$HOME/$rel"
      # already points into this repo (directly or through a linked parent dir)
      [[ "$(realpath "$target" 2>/dev/null)" == "$DOTFILES"/* ]] && continue
      if [[ -L "$target" || ( -e "$target" && ! -d "$target" ) ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$target" "$BACKUP_DIR/$rel"
        info "backed up ~/$rel"
      fi
    done < <(cd "$DOTFILES/$pkg" && find . \( -name .git -o -name .gitignore -o -name .gitmodules \) -prune -o \( -type f -o -type l \) -print | sed 's|^\./||')
  done
}

link_dotfiles() {
  info "Fetching submodules (powerlevel10k, zsh plugins, alacritty themes)"
  git -C "$DOTFILES" submodule update --init --recursive

  backup_conflicts
  info "Linking: ${PACKAGES[*]}"
  (cd "$DOTFILES" && stow --target="$HOME" --restow "${PACKAGES[@]}")
}

# ---------------------------------------------------------------- main

if (( INSTALL_DEPS )); then
  case "$OS" in
    Darwin) install_deps_macos ;;
    Linux)  install_deps_linux ;;
    *) warn "unsupported OS $OS, skipping dependencies" ;;
  esac
fi

have stow || { echo "stow is required (run without --no-deps)" >&2; exit 1; }
link_dotfiles

if have nvim; then
  info "Installing Neovim plugins (Mason will fetch LSP servers on first start)"
  nvim --headless "+Lazy! restore" +qa || warn "plugin install failed, run :Lazy sync inside nvim"
fi

[[ -d "$BACKUP_DIR" ]] && info "Old files saved in $BACKUP_DIR"
[[ "$(basename "${SHELL:-}")" == zsh ]] || warn "your login shell is not zsh, change it with: chsh -s \"\$(command -v zsh)\""
info "Done. Open a new terminal (or run: exec zsh)."
