# ==================================================================== #
#                 ~/.zshrc - Enhanced Configuration                    #
# ==================================================================== #
# This file is structured for clarity and performance.
# Custom user settings are placed in Section 6.
# Tool initializations are placed at the end for path precedence.
# -------------------------------------------------------------------- #

# -------------------------------------------------------------------- #
# SECTION 1: Oh My Zsh - Core Configuration
# -------------------------------------------------------------------- #

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh Theme
ZSH_THEME="dpoggi"

# --- Oh My Zsh Plugins ---
plugins=(
    git zsh-syntax-highlighting zsh-autosuggestions z brew docker node python history macos
)

# --- Oh My Zsh Update Settings ---
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 13

# -------------------------------------------------------------------- #
# SECTION 2: PATH Configuration
# -------------------------------------------------------------------- #

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# -------------------------------------------------------------------- #
# SECTION 3: Shell History Configuration
# -------------------------------------------------------------------- #

export HISTSIZE=10000
export SAVEHIST=10000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS SHARE_HISTORY

# -------------------------------------------------------------------- #
# SECTION 4: Shell Options & Completions
# -------------------------------------------------------------------- #

setopt AUTO_CD PUSHD_IGNORE_DUPS
unsetopt BEEP
zstyle ':completion:*' menu select
zstyle ':completion:*' group-names ''

# -------------------------------------------------------------------- #
# SECTION 5: Source Oh My Zsh
# -------------------------------------------------------------------- #
source $ZSH/oh-my-zsh.sh

# -------------------------------------------------------------------- #
# SECTION 6: User-Defined Aliases & Functions
# -------------------------------------------------------------------- #

# --- General Aliases ---
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
alias reload='source ~/.zshrc && echo "Zsh config reloaded!"'
alias cls='clear'
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; omz update; echo "System update checks complete."'

# --- ls Aliases ---
alias ls='ls -G'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alFh'
alias lsd='ls -l | grep "^d"'

# --- Git Aliases ---
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gaa='git add .'
alias gc='git commit -m'

# --- Python Aliases ---
alias venv='python3 -m venv .venv && echo "Created .venv directory."'
alias venvact='source .venv/bin/activate'

# --- Tmux Workflow Aliases ---
alias tls='tmux ls'
alias tns='tmux new-session -s'
alias tk='tmux kill-session -t'
alias tka="tmux list-sessions | grep -v '(attached)' | cut -d: -f1 | xargs -I {} tmux kill-session -t {}"

# --- Functions ---
mkcd() { mkdir -p "$1" && cd "$1"; }
ic() { cd ~/Library/Mobile\ Documents/com~apple~CloudDocs; }

# Smart tmux attach function to reliably restore sessions with Continuum
ta() {
  # First, check if there's a running server.
  if ! tmux ls > /dev/null 2>&1; then
    echo "No tmux server found. Starting server and restoring sessions..."
    tmux start-server
    # Give Continuum a moment to work. This loop is more robust.
    # It waits until a session actually exists, with a timeout.
    for i in {1..10}; do # Timeout after 2 seconds (10 * 0.2s)
      # We suppress the output of has-session here to avoid the "no server" spam
      if tmux has-session > /dev/null 2>&1; then
        break
      fi
      sleep 0.2
    done
  fi

  # After starting/waiting, check AGAIN if a session exists.
  # This handles all cases: server was already running, or we just started it.
  if tmux has-session > /dev/null 2>&1; then
    # If sessions exist, attach to the first one in the list.
    # This is deterministic and reliable.
    tmux attach-session -t "$(tmux list-sessions -F '#S' | head -n 1)"
  else
    # If, after all that, there are still no sessions (e.g., fresh install),
    # create a new one. This is our final fallback.
    tmux
  fi
}

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