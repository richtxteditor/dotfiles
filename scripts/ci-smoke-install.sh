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

case "$platform" in
    linux)
        printf 'y\n' | ./install.sh
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

        assert_link "$HOME/.zshrc" "$repo_root/platforms/macos/.zshrc"
        assert_link "$HOME/.bash_profile" "$repo_root/platforms/macos/.bash_profile"
        assert_link "$HOME/.config/starship.toml" "$repo_root/platforms/macos/starship.toml"

        command -v brew
        command -v zsh
        command -v tmux
        command -v nvim
        command -v lua
        nvim --version | head -n 1
        ;;
    *)
        echo "Unknown platform argument: $platform" >&2
        exit 1
        ;;
esac
