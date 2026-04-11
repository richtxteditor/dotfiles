# Docker completions must load before compinit / OMZ.
fpath=("$HOME/.docker/completions" $fpath)

export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' mode disabled

# Keep per-keystroke prompt work modest on Linux and large histories.
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_HIGHLIGHT_MAXLENGTH=200

plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)
