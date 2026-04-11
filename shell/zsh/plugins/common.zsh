# Docker completions must load before compinit / OMZ.
fpath=("$HOME/.docker/completions" $fpath)

export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' mode disabled
ZSH_AUTOSUGGEST_STRATEGY=(completion history)
plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab docker node python history)
