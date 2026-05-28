# Docker completions must load before compinit / OMZ.
fpath=("$HOME/.docker/completions" $fpath)

export ZSH="$HOME/.oh-my-zsh"

if [[ -z "${ZSH_CACHE_DIR:-}" ]]; then
  if [[ -n "${XDG_CACHE_HOME:-}" && -d "$XDG_CACHE_HOME" && -w "$XDG_CACHE_HOME" ]]; then
    export ZSH_CACHE_DIR="$XDG_CACHE_HOME/oh-my-zsh"
  elif [[ -d "$HOME/.cache" && -w "$HOME/.cache" ]]; then
    export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
  else
    export ZSH_CACHE_DIR="${TMPDIR:-/tmp}/oh-my-zsh-${UID:-user}"
  fi
fi

case "${DOTFILES_DISABLE_OMZ_COMPFIX:-}" in
  1|true|TRUE|yes|YES|on|ON) export ZSH_DISABLE_COMPFIX=true ;;
  *) unset ZSH_DISABLE_COMPFIX ;;
esac

zstyle ':omz:update' mode disabled

# Keep per-keystroke prompt work modest on Linux and large histories.
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_HIGHLIGHT_MAXLENGTH=200

plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)
