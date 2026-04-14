alias reload='source ~/.zshrc && echo "Config reloaded!"'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias cls='clear'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

if command -v zoxide >/dev/null 2>&1; then
  alias cd='z'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

if command -v eza >/dev/null 2>&1; then
  if dotfiles_use_eza_icons; then
    alias ls='eza --icons --git'
    alias ll='eza --icons --git -l'
    alias la='eza --icons --git -la'
    alias tree='eza --icons --tree --level=2'
  else
    alias ls='eza --git'
    alias ll='eza --git -l'
    alias la='eza --git -la'
    alias tree='eza --tree --level=2'
  fi
fi
alias lg='lazygit'
alias fff='fff-mcp'

alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gaa='git add .'
alias gc='git commit -m'

alias venv='python3 -m venv .venv && echo "Created .venv"'
alias venvact='source .venv/bin/activate'
alias explain="gemini 'Explain this error message and suggest a fix:'"

alias tls='tmux ls'
alias tk='tmux kill-session -t'
alias tka="tmux list-sessions | grep -v '(attached)' | cut -d: -f1 | xargs -I {} tmux kill-session -t {}"

alias paneps="ps -t $(tty | sed 's#/dev/##') -o pid,ppid,stat,command"

(( $+aliases[bbu] )) && unalias bbu

function bbu {
  if ! command -v brew >/dev/null 2>&1; then
    echo "brew not installed"
    return 1
  fi

  brew bundle dump --file="$DOTFILES_ROOT/Brewfile" --force && echo "Brewfile updated!"
}
