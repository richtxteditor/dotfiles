if command -v grc >/dev/null 2>&1; then
  GRC_ZSH="/opt/homebrew/etc/grc.zsh"
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/usr/local/etc/grc.zsh"
  fi
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/home/linuxbrew/.linuxbrew/etc/grc.zsh"
  fi
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="$HOME/.linuxbrew/etc/grc.zsh"
  fi
  [[ -r "$GRC_ZSH" ]] && source "$GRC_ZSH"
fi

bindkey '^@' autosuggest-accept
bindkey -M menuselect '^i' menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if [[ -f "$DOTFILES_ROOT/.fzf.zsh" ]]; then
  source "$DOTFILES_ROOT/.fzf.zsh"
elif command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
