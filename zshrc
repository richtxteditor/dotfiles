# ==================================================================== #
#                 ~/.zshrc - Enhanced Configuration                    #
# ==================================================================== #
# This file is structured for clarity, performance, and correct load order.
# -------------------------------------------------------------------- #

# -------------------------------------------------------------------- #
# SECTION 1: PATH Configuration
# -------------------------------------------------------------------- #

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.composer/vendor/bin:$PATH"

# -------------------------------------------------------------------- #
# SECTION 2: Oh My Zsh - Core Configuration
# -------------------------------------------------------------------- #

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="dpoggi"
plugins=(
    git zsh-syntax-highlighting zsh-autosuggestions z brew docker node python history macos
)
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 13

# -------------------------------------------------------------------- #
# SECTION 3: Source Oh My Zsh
# -------------------------------------------------------------------- #
source $ZSH/oh-my-zsh.sh

# -------------------------------------------------------------------- #
# SECTION 4: User-Defined Aliases & Functions
# -------------------------------------------------------------------- #

# --- Aliases ---
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
alias reload='source ~/.zshrc && echo "Zsh config reloaded!"'
alias cls='clear'
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; omz update; echo "System update checks complete."'
alias bbu='brew bundle dump --file=~/dotfiles/Brewfile --force && echo "Brewfile updated!"'
alias ls='ls -G'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alFh'
alias lsd='ls -l | grep "^d"'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autosthat'
alias gaa='git add .'
alias gc='git commit -m'
alias venv='python3 -m venv .venv && echo "Created .venv directory."'
alias venvact='source .venv/bin/activate'
alias tls='tmux ls'
alias tns='tmux new-session -s'
alias tk='tmux kill-session -t'
alias tka="tmux list-sessions | grep -v '(attached)' | cut -d: -f1 | xargs -I {} tmux kill-session -t {}"

# --- Functions ---
mkcd() { mkdir -p "$1" && cd "$1"; }
ic() { cd ~/Library/Mobile\ Documents/com~apple~CloudDocs; }
ta() {
  if ! tmux ls > /dev/null 2>&1; then
    echo "No tmux server found. Starting server and restoring sessions..."
    tmux start-server
    for i in {1..10}; do
      if tmux has-session > /dev/null 2>&1; then break; fi
      sleep 0.2
    done
  fi
  if tmux has-session > /dev/null 2>&1; then
    tmux attach-session -t "$(tmux list-sessions -F '#S' | head -n 1)"
  else
    tmux
  fi
}

# -------------------------------------------------------------------- #
# SECTION 5: Shell Options, History, and Completions
# -------------------------------------------------------------------- #

# --- History ---
export HISTSIZE=10000
export SAVEHIST=10000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS SHARE_HISTORY

# --- General Behavior ---
setopt AUTO_CD PUSHD_IGNORE_DUPS
unsetopt BEEP

# --- Completion System ---
# These styles must be set for the menu to work correctly.
zstyle ':completion:*' menu select
zstyle ':completion:*' group-names ''

# -------------------------------------------------------------------- #
# SECTION 6: Custom Keybindings & Widgets
# This section must come AFTER the completion system is configured.
# -------------------------------------------------------------------- #

# --- Smart Tab Widget ---
# This widget provides context-aware Tab completion.
smart-tab-completion() {
  if [[ -n "${ZSH_AUTOSUGGEST_SUGGESTION-}" ]]; then
    # If a zsh-autosuggestion is available, accept it.
    zle autosuggest-accept
  else
    # Otherwise, trigger the interactive completion menu.
    zle menu-select
  fi
}

# Register our new function as a ZLE widget.
zle -N smart-tab-completion

# Bind Tab ('^i') to our new smart widget.
bindkey '^i' smart-tab-completion

# --- In-Menu Cycling Keybindings ---
# These bindings ONLY apply when the completion menu is active.
# Bind Tab to cycle forward through the completion menu.
bindkey -M menuselect '^i' menu-complete
# Bind Shift-Tab to cycle backward through the completion menu.
bindkey -M menuselect 'ZA' reverse-menu-complete

# -------------------------------------------------------------------- #
# SECTION 7: Environment Variables
# -------------------------------------------------------------------- #

export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8

# -------------------------------------------------------------------- #
# SECTION 8: Version & Tool Initializations
# -------------------------------------------------------------------- #

# --- NVM (Node Version Manager) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Pyenv (Python Version Manager) ---
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"

# --- rbenv (Ruby Version Manager) ---
eval "$(rbenv init - zsh)"

# --- Auto-generated Initializers ---
export PATH="$HOME/.opencode/bin:$PATH"
path=('$HOME/.juliaup/bin' $path)
export PATH