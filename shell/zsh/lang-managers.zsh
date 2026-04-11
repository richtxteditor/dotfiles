export NVM_DIR="$HOME/.nvm"
function load_nvm() {
    for cmd in nvm node npm npx yarn pnpm; do unset -f $cmd 2>/dev/null; done
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

for cmd in nvm node npm npx yarn pnpm; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() { load_nvm; $cmd \"\$@\"; }"
    fi
done

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
load_pyenv() {
    unset -f pyenv python python3 pip pip3 2>/dev/null
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
}

for cmd in pyenv python python3 pip pip3; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() { load_pyenv; $cmd \"\$@\"; }"
    fi
done

load_rbenv() {
    unset -f rbenv ruby gem bundle bundler irb 2>/dev/null
    if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
    fi
}

for cmd in rbenv ruby gem bundle bundler irb; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() { load_rbenv; $cmd \"\$@\"; }"
    fi
done

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
