#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

# shellcheck source=../config/toolchain.sh
. "$repo_root/config/toolchain.sh"

failures=0

fail() {
    failures=$((failures + 1))
    printf 'FAIL %s\n' "$1"
}

pass() {
    printf 'PASS %s\n' "$1"
}

require_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        fail "Missing file: $file"
        return 1
    fi
}

assert_token_in_file() {
    local token="$1"
    local file="$2"

    if grep -Fq "\"$token\"" "$file"; then
        pass "$token declared in $(basename "$file")"
    else
        fail "$token missing from $file"
    fi
}

require_file "$repo_root/nvim/lua/plugins/lsp.lua" || true
require_file "$repo_root/nvim/lua/plugins/mason-tools.lua" || true
require_file "$repo_root/nvim/lua/plugins/treesitter.lua" || true
require_file "$repo_root/nvim/lua/plugins/devdocs.lua" || true

if command -v nvim >/dev/null 2>&1; then
    if nvim --headless '+quitall' >/dev/null 2>&1; then
        pass "nvim headless startup"
    else
        fail "nvim headless startup"
    fi
else
    fail "nvim executable missing"
fi

for server in "${DOTFILES_NVIM_LSP_SERVERS[@]}"; do
    assert_token_in_file "$server" "$repo_root/nvim/lua/plugins/lsp.lua"
done

for tool in "${DOTFILES_NVIM_MASON_TOOLS[@]}"; do
    assert_token_in_file "$tool" "$repo_root/nvim/lua/plugins/mason-tools.lua"
done

for language in "${DOTFILES_NVIM_TREESITTER_LANGUAGES[@]}"; do
    assert_token_in_file "$language" "$repo_root/nvim/lua/plugins/treesitter.lua"
done

for entry in "${DOTFILES_DEVDOCS_ENTRIES[@]}"; do
    assert_token_in_file "$entry" "$repo_root/nvim/lua/plugins/devdocs.lua"
done

if grep -Fq 'texdoc' "$repo_root/nvim/lua/plugins/devdocs.lua"; then
    pass "texdoc integration declared in devdocs plugin"
else
    fail "texdoc integration missing from devdocs plugin"
fi

if [[ "$failures" -gt 0 ]]; then
    exit 1
fi
