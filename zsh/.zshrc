# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH (no duplicates, works on both macOS and Linux)
typeset -U path PATH
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.pixi/bin" ]] && path=("$HOME/.pixi/bin" $path)
[[ -d "$HOME/vcpkg" ]] && path+=("$HOME/vcpkg")

# Prompt
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History setup
HISTFILE=$HOME/.zhistory
HISTSIZE=50000
SAVEHIST=50000
setopt share_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

command -v eza >/dev/null && alias ls="eza --color=always --icons=always"
command -v bat >/dev/null && alias cat="bat --paging=never"

# English messages from CLI tools (git, brew, ...); dates/numbers keep the system locale
export LC_MESSAGES=en_US.UTF-8

export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt

# nvm: sourcing nvm.sh costs a few hundred ms, so only put the newest installed
# node on PATH and load nvm itself the first time the `nvm` command is used.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _nvm_node=($NVM_DIR/versions/node/*(N/nOn[1]))
  (( $#_nvm_node )) && ! command -v node >/dev/null && path=("$_nvm_node/bin" $path)
  unset _nvm_node
  nvm() {
    unset -f nvm
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

ZSH_PLUGINS=~/.oh-my-zsh/custom/plugins

# Completion: Tab completes subcommands/options (git, brew, docker, ...)
fpath=($ZSH_PLUGINS/zsh-completions/src $fpath)
[[ -n "$HOMEBREW_PREFIX" ]] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
autoload -Uz compinit
# rebuild the completion cache at most once a day, otherwise start fast from it
if [[ -n ~/.zcompdump(#qN.mh+24) || ! -f ~/.zcompdump ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no                              # fzf-tab draws the menu
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath 2>/dev/null || ls $realpath'

# fzf: Ctrl+R history, Ctrl+T insert file, Alt+C cd into directory
if command -v fzf >/dev/null; then
  command -v fd >/dev/null && {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  }
  command -v bat >/dev/null && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  command -v eza >/dev/null && export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {}'"
  if _fzf_init="$(fzf --zsh 2>/dev/null)"; then
    eval "$_fzf_init"
  else  # fzf < 0.48 (e.g. Ubuntu 24.04) ships the scripts separately
    for f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do [[ -r $f ]] && source $f; done
  fi
  unset _fzf_init
fi

# Plugins: fzf-tab after compinit and before the widgets-wrapping plugins
[[ -r $ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh ]] && source $ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh
[[ -r $ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source $ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh

# zoxide: `z <part of path>` jumps to a frequently used directory, `zi` picks with fzf
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# zsh-syntax-highlighting must be sourced last
[[ -r $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
