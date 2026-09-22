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

# Plugins (zsh-syntax-highlighting must be sourced last)
[[ -r ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
