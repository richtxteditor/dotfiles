#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

platform="${1:-}"
mode="${2:-full}"

if [[ -z "$platform" ]]; then
    case "$(uname -s)" in
        Darwin) platform="macos" ;;
        Linux) platform="linux" ;;
        *)
            echo "Unsupported platform: $(uname -s)" >&2
            exit 1
            ;;
    esac
fi

assert_link() {
    local target="$1"
    local expected="$2"

    test "$(readlink "$target")" = "$expected"
}

assert_clean_worktree() {
    git diff --exit-code
    test -z "$(git status --short)"
}

smoke_shell_startup() {
    zsh -ic 'alias ls >/dev/null; command -v nvim >/dev/null'
    bash -lc 'command -v nvim >/dev/null'
}

smoke_tmux_startup() {
    local socket="ci_smoke_$$"
    local tmux_tmpdir
    tmux_tmpdir="$(mktemp -d /tmp/dotfiles-tmux.XXXXXX)"
    TMUX_TMPDIR="$tmux_tmpdir" tmux -L "$socket" -f "$HOME/.tmux.conf" start-server \; show -g prefix \; kill-server >/dev/null
}

smoke_nvim_startup() {
    nvim --headless '+quitall'
}

case "$platform" in
    linux)
        printf 'y\n' | ./install.sh
        printf 'y\n' | ./install.sh --skip-deps
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

        assert_link "$HOME/.zshrc" "$repo_root/platforms/ubuntu/.zshrc"
        assert_link "$HOME/.bash_profile" "$repo_root/platforms/ubuntu/.bash_profile"
        assert_link "$HOME/.config/starship.toml" "$repo_root/platforms/ubuntu/starship.toml"

        command -v zsh
        command -v tmux
        command -v tree-sitter
        command -v node
        command -v npm
        command -v ruby
        command -v go
        command -v php
        command -v composer
        command -v javac
        command -v luarocks
        "$HOME/.local/bin/nvim" --version | head -n 1
        smoke_shell_startup
        smoke_tmux_startup
        smoke_nvim_startup
        assert_clean_worktree
        ;;
    macos)
        case "$mode" in
            full) printf 'y\n' | ./install.sh ;;
            skip-deps) printf 'y\n' | ./install.sh --skip-deps ;;
            *)
                echo "Unknown macOS install mode: $mode" >&2
                exit 1
                ;;
        esac
        printf 'y\n' | ./install.sh --skip-deps

        assert_link "$HOME/.zshrc" "$repo_root/platforms/macos/.zshrc"
        assert_link "$HOME/.bash_profile" "$repo_root/platforms/macos/.bash_profile"
        assert_link "$HOME/.config/starship.toml" "$repo_root/platforms/macos/starship.toml"

        command -v brew
        command -v zsh
        command -v tmux
        command -v nvim
        command -v lua
        nvim --version | head -n 1
        smoke_shell_startup
        smoke_tmux_startup
        smoke_nvim_startup
        assert_clean_worktree
        ;;
    *)
        echo "Unknown platform argument: $platform" >&2
        exit 1
        ;;
esac
