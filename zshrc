# --- Path Configuration ---
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
# Julia
path=('$HOME/.juliaup/bin' $path)
export PATH

# --- Environment ---
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export HISTSIZE=10000
export SAVEHIST=10000

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# REMOVED 'z' plugin to avoid conflict with zoxide
plugins=(git zsh-syntax-highlighting zsh-autosuggestions brew docker node python history macos)
zstyle ':omz:update' mode reminder
source $ZSH/oh-my-zsh.sh

# --- Options ---
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt AUTO_CD PUSHD_IGNORE_DUPS
unsetopt BEEP
zstyle ':completion:*' menu select
zstyle ':completion:*' group-names ''

# --- Aliases ---

# System
alias reload='source ~/.zshrc && echo "Config reloaded!"'
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
alias cls='clear'
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; omz update; echo "Updates complete."'
alias bbu='brew bundle dump --file=~/dotfiles/Brewfile --force && echo "Brewfile updated!"'

# Modern Unix Replacements (Eza/Bat/Lazygit)
alias cat='bat'
alias ls='eza --icons --git'
alias ll='eza --icons --git -l'
alias la='eza --icons --git -la'
alias tree='eza --icons --tree --level=2'
alias lg='lazygit'

# Git (Standard)
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autosthat'
alias gaa='git add .'
alias gc='git commit -m'

# Python / AI
alias venv='python3 -m venv .venv && echo "Created .venv"'
alias venvact='source .venv/bin/activate'
alias explain="gemini 'Explain this error message and suggest a fix:'"

# Tmux
alias tls='tmux ls'
alias tk='tmux kill-session -t'
alias tka="tmux list-sessions | grep -v '(attached)' | cut -d: -f1 | xargs -I {} tmux kill-session -t {}"

# --- Functions ---

# Mkdir + CD
mkcd() { mkdir -p "$1" && cd "$1"; }

# iCloud Shortcut
ic() { cd ~/Library/Mobile\ Documents/com~apple~CloudDocs; }

# Smart Tmux Attach/Create
ta() {
  if tmux has-session 2>/dev/null; then
    tmux attach-session -t "$(tmux list-sessions -F '#S' | head -n 1)"
  else
    tmux new-session
  fi
}

# Nom Wrapper (Theme Auto-Switch)
nom() {
    local CONFIG="$HOME/Library/Application Support/nom/config.yml"
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
        sed -i '' 's/glamour: light/glamour: dark/' "$CONFIG"
    else
        sed -i '' 's/glamour: dark/glamour: light/' "$CONFIG"
    fi
    command nom "$@"
}

# Gemini Wrapper (Theme Auto-Switch)
gemini() {
    local CONFIG="$HOME/.gemini/settings.json"
    if [[ -f "$CONFIG" ]]; then
        if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
            sed -i '' 's/"theme": "[^"]*"/"theme": "Atom One"/' "$CONFIG"
        else
            sed -i '' 's/"theme": "[^"]*"/"theme": "Google Code"/' "$CONFIG"
        fi
    fi
    command gemini "$@"
}

# --- Smart Tab Completion ---
smart-tab-completion() {
  if [[ -n "${ZSH_AUTOSUGGEST_SUGGESTION-}" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N smart-tab-completion
bindkey '^i' smart-tab-completion
bindkey -M menuselect '^i' menu-complete
bindkey -M menuselect 'ZA' reverse-menu-complete

# --- Custom Prompt ---
function set_prompt() {
    # Path Shortening
    local TRUNC_LENGTH=2
    local PWD_PRETTY=${PWD/#$HOME/\~}
    local -a path_parts=("${(@s:/:)PWD_PRETTY}")
    if (( ${#path_parts[@]} > TRUNC_LENGTH + 1 )); then
        PROMPT_PWD="${path_parts[1]}/…/${(j:/:)path_parts[-TRUNC_LENGTH,-1]}"
    else
        PROMPT_PWD=$PWD_PRETTY
    fi

    # Git Status
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        if [[ -n "$(git status --porcelain)" ]]; then
            local GIT_STATE='%F{yellow}⚡️%f'
        else
            local GIT_STATE='%F{green}✓%f'
        fi
        local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        PROMPT_GIT_INFO="(%F{yellow}${GIT_BRANCH}%f ${GIT_STATE})"
    else
        PROMPT_GIT_INFO=""
    fi
}
autoload -U add-zsh-hook
add-zsh-hook precmd set_prompt
PROMPT='%F{green}%n%f@%F{cyan}%m%f:%F{141}${PROMPT_PWD}%f${PROMPT_GIT_INFO} %F{red}»%f '

# --- Tool Initializations ---

# Zoxide (Smart CD - replaces 'z')
eval "$(zoxide init zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Language Managers
eval "$(pyenv init -)"
eval "$(rbenv init - zsh)"
