export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HISTSIZE=50000
export SAVEHIST=50000

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  bat() { command batcat "$@"; }
fi

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  unset MANPAGER
fi
