if command -v grc >/dev/null 2>&1; then
  GRC_ZSH="/opt/homebrew/etc/grc.zsh"
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/usr/local/etc/grc.zsh"
  fi
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/etc/grc.zsh"
  fi
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/usr/share/grc/grc.zsh"
  fi
  [[ -r "$GRC_ZSH" ]] && source "$GRC_ZSH"
fi

bindkey '^@' autosuggest-accept
bindkey -M menuselect '^i' menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    if dotfiles_is_wsl && dotfiles_is_windows_mount_path; then
        PROMPT='%F{green}%n%f@%F{cyan}%m%f:%F{magenta}%2~%f %(?.%F{green}.%F{red})»%f '
    else
        eval "$(starship init zsh)"
    fi
fi

if [[ -f "$DOTFILES_ROOT/.fzf.zsh" ]]; then
  source "$DOTFILES_ROOT/.fzf.zsh"
elif command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
