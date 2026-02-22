# --- Path Configuration ---
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
path=("$HOME/.juliaup/bin" $path)
export PATH

# Resolve this config directory for relative sources
ZSHRC_DIR="${${(%):-%x}:A:h}"

# --- Environment ---
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export HISTSIZE=50000
export SAVEHIST=50000

# Optimize: Cache the dark mode check (takes ~9ms otherwise)
if [[ -z "$APPLE_INTERFACE_STYLE" ]]; then
    export APPLE_INTERFACE_STYLE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
fi

if [[ "$APPLE_INTERFACE_STYLE" == "Dark" ]]; then
  export BAT_THEME="OneHalfDark"
else
  export BAT_THEME="OneHalfLight"
fi
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- Docker Completions (Must be before compinit/OMZ) ---
fpath=($HOME/.docker/completions $fpath)

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX=true
# Optimize: Disable OMZ update check at startup (run manually with 'omz update')
zstyle ':omz:update' mode disabled
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab brew docker node python history macos)
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
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias cls='clear'
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; omz update; echo "Updates complete."'
alias bbu='brew bundle dump --file="$ZSHRC_DIR/Brewfile" --force && echo "Brewfile updated!"'
alias icloud='~/Library/Mobile\ Documents/com~apple~CloudDocs'

# Safety & Navigation
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias cd='z' # Use zoxide for cd

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
alias gpl='git pull --rebase --autostash'
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
    if [[ "$APPLE_INTERFACE_STYLE" == "Dark" ]]; then
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
        if [[ "$APPLE_INTERFACE_STYLE" == "Dark" ]]; then
            sed -i '' 's/"theme": "[^"]*"/"theme": "Atom One"/' "$CONFIG"
        else
            sed -i '' 's/"theme": "[^"]*"/"theme": "Google Code"/' "$CONFIG"
        fi
    fi
    command gemini "$@"
}

# Highlight no-arg command output with bat (curated list)
_noarg_hl() {
    local cmd="$1"
    shift
    local wants_help=0
    local wants_verbose=0
    if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        wants_help=1
    elif [[ $# -eq 1 && ( "$1" == "-v" || "$1" == "--verbose" ) ]]; then
        wants_verbose=1
    elif [[ $# -eq 2 ]]; then
        if [[ ( "$1" == "-h" || "$1" == "--help" ) && ( "$2" == "-v" || "$2" == "--verbose" ) ]]; then
            wants_help=1
            wants_verbose=1
        elif [[ ( "$2" == "-h" || "$2" == "--help" ) && ( "$1" == "-v" || "$1" == "--verbose" ) ]]; then
            wants_help=1
            wants_verbose=1
        fi
    fi
    if [[ -z "${_HAS_BAT+x}" ]]; then
        if command -v bat >/dev/null 2>&1; then
            _HAS_BAT=1
        else
            _HAS_BAT=0
        fi
    fi
    if [[ ( $# -eq 0 || $wants_help -eq 1 || $wants_verbose -eq 1 ) && -t 1 && $_HAS_BAT -eq 1 ]]; then
        command "$cmd" "$@" 2>&1 | bat -l help -p
        local -a ps
        ps=(${pipestatus[@]})
        return $ps[1]
    else
        command "$cmd" "$@"
    fi
}

# Explicit wrappers (avoid loop + avoid shadowing existing aliases/functions)
if ! alias ssh >/dev/null 2>&1 && ! (( $+functions[ssh] )); then
  ssh() { _noarg_hl ssh "$@"; }
fi
if ! alias tldr >/dev/null 2>&1 && ! (( $+functions[tldr] )); then
  tldr() { _noarg_hl tldr "$@"; }
fi
if ! alias git >/dev/null 2>&1 && ! (( $+functions[git] )); then
  git() { _noarg_hl git "$@"; }
fi
if ! alias rg >/dev/null 2>&1 && ! (( $+functions[rg] )); then
  rg() { _noarg_hl rg "$@"; }
fi
if ! alias curl >/dev/null 2>&1 && ! (( $+functions[curl] )); then
  curl() { _noarg_hl curl "$@"; }
fi
if ! alias jq >/dev/null 2>&1 && ! (( $+functions[jq] )); then
  jq() { _noarg_hl jq "$@"; }
fi
if ! alias docker >/dev/null 2>&1 && ! (( $+functions[docker] )); then
  docker() { _noarg_hl docker "$@"; }
fi
if ! alias kubectl >/dev/null 2>&1 && ! (( $+functions[kubectl] )); then
  kubectl() { _noarg_hl kubectl "$@"; }
fi

# GRC (generic colorizer) for common commands
# Optimize: avoid brew --prefix call (~22ms)
if command -v grc >/dev/null 2>&1; then
  GRC_ZSH="/opt/homebrew/etc/grc.zsh"
  if [[ ! -r "$GRC_ZSH" ]]; then
    GRC_ZSH="/usr/local/etc/grc.zsh"
  fi
  [[ -r "$GRC_ZSH" ]] && source "$GRC_ZSH"
fi

bindkey '^@' autosuggest-accept
bindkey -M menuselect '^i' menu-complete
bindkey -M menuselect 'ZA' reverse-menu-complete

# --- Modern Prompts & Integrations ---

# Starship (Prompt)
eval "$(starship init zsh)"

# FZF (Fuzzy Finder Keybindings & Completion)
if [[ -f "$ZSHRC_DIR/fzf.zsh" ]]; then
  source "$ZSHRC_DIR/fzf.zsh"
else
  source <(fzf --zsh)
fi

# Zoxide (Smart CD - replaces 'z')
eval "$(zoxide init zsh)"

# --- Tool Initializations ---

# NVM (Lazy Load for Speed)
export NVM_DIR="$HOME/.nvm"
function load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
# Create placeholder functions that load NVM then run the command
for cmd in nvm node npm npx yarn pnpm; do
    eval "$cmd() { unset -f $cmd; load_nvm; $cmd \"\$@\"; }"
done

# Language Managers

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
