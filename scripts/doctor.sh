#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

# shellcheck source=../shell/shared/platform.sh
. "$repo_root/shell/shared/platform.sh"
# shellcheck source=../config/toolchain.sh
. "$repo_root/config/toolchain.sh"

failures=0
warnings=0
run_nvim_verify=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-nvim) run_nvim_verify=0 ;;
        *)
            echo "Unknown doctor option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

pass() {
    printf 'PASS %s\n' "$1"
}

warn() {
    warnings=$((warnings + 1))
    printf 'WARN %s\n' "$1"
}

fail() {
    failures=$((failures + 1))
    printf 'FAIL %s\n' "$1"
}

expected_link_target() {
    local path="$1"
    local platform_dir

    if dotfiles_is_linux; then
        platform_dir="ubuntu"
    else
        platform_dir="macos"
    fi

    case "$path" in
        ".zshrc") printf '%s\n' "$repo_root/platforms/$platform_dir/.zshrc" ;;
        ".bash_profile") printf '%s\n' "$repo_root/platforms/$platform_dir/.bash_profile" ;;
        ".tmux.conf") printf '%s\n' "$repo_root/.tmux.conf" ;;
        ".config/nvim") printf '%s\n' "$repo_root/nvim" ;;
        ".config/starship.toml") printf '%s\n' "$repo_root/platforms/$platform_dir/starship.toml" ;;
        *) return 1 ;;
    esac
}

check_link() {
    local relative_target="$1"
    local absolute_target="$HOME/$relative_target"
    local expected

    expected="$(expected_link_target "$relative_target")" || return 0

    if [[ ! -L "$absolute_target" ]]; then
        fail "$relative_target is not a symlink"
        return
    fi

    if [[ "$(readlink "$absolute_target")" != "$expected" ]]; then
        fail "$relative_target points to $(readlink "$absolute_target"), expected $expected"
        return
    fi

    pass "$relative_target points to expected dotfiles target"
}

check_tool() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool is installed"
    else
        fail "$tool is missing"
    fi
}

tool_version() {
    local tool="$1"

    case "$tool" in
        nvim) nvim --version 2>/dev/null | awk 'NR==1 { gsub(/^v/, "", $2); print $2 }' ;;
        node) node --version 2>/dev/null | sed 's/^v//' ;;
        npm) npm --version 2>/dev/null ;;
        go) go version 2>/dev/null | awk '{ gsub(/^go/, "", $3); print $3 }' ;;
        php) php -v 2>/dev/null | awk 'NR==1 { print $2 }' ;;
        composer) composer --version 2>/dev/null | awk '{ print $3 }' ;;
        tree-sitter) tree-sitter --version 2>/dev/null | awk '{ print $2 }' ;;
        *) return 1 ;;
    esac
}

check_min_version() {
    local tool="$1"
    local have need

    need="$(dotfiles_min_version_for "$tool")"
    if [[ -z "$need" ]]; then
        return
    fi

    if ! command -v "$tool" >/dev/null 2>&1; then
        fail "$tool is missing; need at least $need"
        return
    fi

    have="$(tool_version "$tool" || true)"
    if [[ -z "$have" ]]; then
        warn "Could not determine version for $tool"
        return
    fi

    if dotfiles_version_ge "$have" "$need"; then
        pass "$tool version $have satisfies minimum $need"
    else
        fail "$tool version $have is below minimum $need"
    fi
}

check_locale() {
    if ! dotfiles_is_linux; then
        return
    fi

    if locale 2>/dev/null | grep -q 'UTF-8'; then
        pass "UTF-8 locale available"
    else
        fail "UTF-8 locale not detected"
    fi
}

check_default_shell() {
    if [[ "${SHELL:-}" == *zsh ]]; then
        pass "Default shell uses zsh"
    else
        warn "Default shell is ${SHELL:-unset}"
    fi
}

verify_nvim_contract() {
    if [[ "$run_nvim_verify" -ne 1 ]]; then
        return
    fi

    if [[ ! -f "$repo_root/scripts/verify-nvim.sh" ]]; then
        fail "scripts/verify-nvim.sh is missing"
        return
    fi

    if bash "$repo_root/scripts/verify-nvim.sh"; then
        pass "Neovim contract verification passed"
    else
        fail "Neovim contract verification failed"
    fi
}

printf 'Dotfiles doctor for %s\n' "$(dotfiles_platform)"

for path in "${DOTFILES_VERIFY_LINKS_COMMON[@]}"; do
    check_link "$path"
done

if dotfiles_is_linux; then
    for tool in "${DOTFILES_LINUX_VERIFY_TOOLS[@]}"; do
        check_tool "$tool"
    done
else
    for tool in "${DOTFILES_MACOS_VERIFY_TOOLS[@]}"; do
        check_tool "$tool"
    done
fi

check_min_version nvim
check_min_version node
check_min_version npm
check_min_version go
check_min_version php
check_min_version composer
check_min_version tree-sitter
check_locale
check_default_shell
verify_nvim_contract

printf 'Doctor summary: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
if [[ "$failures" -gt 0 ]]; then
    exit 1
fi
