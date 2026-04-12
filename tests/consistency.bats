#!/usr/bin/env bats

# Static analysis tests: verify repo files are internally consistent.
# These tests don't execute anything — just check that references between
# files are valid. Fast, deterministic, no dependencies.

@test "gitconfig excludesFile matches gitignore_global" {
  # Parse the excludesFile value from .gitconfig
  run grep 'excludesFile' .gitconfig
  [ "$status" -eq 0 ]
  [[ "$output" == *"~/.gitignore_global"* ]]

  # The referenced file must exist in the repo
  [ -f ".gitignore_global" ]
}

@test "all install entrypoints referenced by install.sh exist in repo" {
  local expected=(
    ".zshrc"
    ".tmux.conf"
    ".bash_profile"
    ".fzf.zsh"
    ".gitconfig"
    ".gitignore_global"
    "nvim"
    "starship.toml"
    "ghostty/config.macos"
    "ghostty/config.linux"
    "platforms/macos/.zshrc"
    "platforms/ubuntu/.zshrc"
    "platforms/macos/.bash_profile"
    "platforms/ubuntu/.bash_profile"
    "platforms/macos/starship.toml"
    "platforms/ubuntu/starship.toml"
    "tmux/common.conf"
    "tmux/macos.conf"
    "tmux/linux.conf"
    "claude/CLAUDE.md"
  )

  for f in "${expected[@]}"; do
    [ -e "$f" ] || { echo "Missing install entrypoint: $f"; false; }
  done
}

@test "Brewfile exists and is non-empty" {
  [ -f "Brewfile" ]
  local lines
  lines=$(grep -cv '^\s*#\|^\s*$' Brewfile)
  [ "$lines" -gt 0 ]
}

@test "CI workflow references cross-platform smoke install script" {
  [ -f ".github/workflows/test.yml" ]
  [ -f ".github/workflows/full-bootstrap.yml" ]
  [ -f "scripts/ci-smoke-install.sh" ]
  grep -q "bash ./scripts/ci-smoke-install.sh linux" .github/workflows/test.yml
  grep -q "bash ./scripts/ci-smoke-install.sh macos skip-deps" .github/workflows/test.yml
  grep -q "bash ./scripts/ci-smoke-install.sh linux" .github/workflows/full-bootstrap.yml
  grep -q "bash ./scripts/ci-smoke-install.sh macos full" .github/workflows/full-bootstrap.yml
}

@test "full bootstrap workflow keeps manual, nightly, and both-OS release coverage" {
  [ -f ".github/workflows/full-bootstrap.yml" ]

  grep -q '^  workflow_dispatch:' .github/workflows/full-bootstrap.yml
  grep -q '^  schedule:' .github/workflows/full-bootstrap.yml
  grep -q 'cron: "0 7 \* \* \*"' .github/workflows/full-bootstrap.yml
  grep -Fq 'name: ${{ matrix.os }} full bootstrap' .github/workflows/full-bootstrap.yml
  grep -Fq 'runs-on: ${{ matrix.os }}' .github/workflows/full-bootstrap.yml
  grep -q 'fail-fast: false' .github/workflows/full-bootstrap.yml
  grep -q 'ubuntu-latest' .github/workflows/full-bootstrap.yml
  grep -q 'macos-latest' .github/workflows/full-bootstrap.yml
}

@test "bootstrap e2e covers both macOS and Linux install paths" {
  [ -f "tests/bootstrap_e2e.bats" ]

  grep -q '@test "installed zsh entrypoint bootstraps from symlinked home"' tests/bootstrap_e2e.bats
  grep -q '@test "installed linux zsh entrypoint bootstraps from symlinked home"' tests/bootstrap_e2e.bats

  grep -q '@test "installed macOS bash entrypoint bootstraps from symlinked home"' tests/bootstrap_e2e.bats
  grep -q '@test "installed linux bash entrypoint bootstraps from symlinked home"' tests/bootstrap_e2e.bats

  grep -q '@test "installed tmux config parses after install"' tests/bootstrap_e2e.bats
  grep -q '@test "installed linux tmux config parses after install"' tests/bootstrap_e2e.bats

  grep -q '@test "installed neovim config loads headless with stub lazy bootstrap"' tests/bootstrap_e2e.bats
  grep -q '@test "installed linux neovim config loads headless with stub lazy bootstrap"' tests/bootstrap_e2e.bats
}

@test "nvim init.lua entry point exists" {
  [ -f "nvim/init.lua" ]

  # Verify it requires the expected core modules
  grep -q "require.*core.lazy" nvim/init.lua
  grep -q "require.*core.platform" nvim/init.lua
  grep -q "require.*core.options" nvim/init.lua
  grep -q "require.*core.keymaps" nvim/init.lua
}

@test "every lua file required by init.lua exists" {
  # init.lua requires core.lazy, core.platform, core.options, core.keymaps
  [ -f "nvim/lua/core/lazy.lua" ]
  [ -f "nvim/lua/core/platform/init.lua" ]
  [ -f "nvim/lua/core/platform/common.lua" ]
  [ -f "nvim/lua/core/platform/macos.lua" ]
  [ -f "nvim/lua/core/platform/linux.lua" ]
  [ -f "nvim/lua/core/options.lua" ]
  [ -f "nvim/lua/core/keymaps.lua" ]
}

@test "shell entrypoints source modular shell files" {
  local modules=(
    "shell/shared/platform.sh"
    "shell/bash/profile.bash"
    "shell/bash/entrypoint.bash"
    "shell/bash/common.bash"
    "shell/bash/macos.bash"
    "shell/bash/linux.bash"
    "shell/zsh/entrypoint.zsh"
    "shell/zsh/path.zsh"
    "shell/zsh/path/common.zsh"
    "shell/zsh/path/macos.zsh"
    "shell/zsh/path/linux.zsh"
    "shell/zsh/environment.zsh"
    "shell/zsh/platform.zsh"
    "shell/zsh/platform/common.zsh"
    "shell/zsh/platform/macos.zsh"
    "shell/zsh/platform/linux.zsh"
    "shell/zsh/plugins.zsh"
    "shell/zsh/plugins/common.zsh"
    "shell/zsh/plugins/macos.zsh"
    "shell/zsh/plugins/linux.zsh"
    "shell/zsh/options.zsh"
    "shell/zsh/aliases.zsh"
    "shell/zsh/functions.zsh"
    "shell/zsh/integrations.zsh"
    "shell/zsh/lang-managers.zsh"
  )

  grep -q "platforms/macos/.zshrc" .zshrc
  grep -q "platforms/ubuntu/.zshrc" .zshrc
  grep -q "platforms/macos/.bash_profile" .bash_profile
  grep -q "platforms/ubuntu/.bash_profile" .bash_profile
  grep -q "shell/zsh/entrypoint.zsh" platforms/macos/.zshrc
  grep -q "shell/zsh/entrypoint.zsh" platforms/ubuntu/.zshrc
  grep -q "shell/bash/entrypoint.bash" platforms/macos/.bash_profile
  grep -q "shell/bash/entrypoint.bash" platforms/ubuntu/.bash_profile
  grep -q "source-file ~/.tmux/common.conf" .tmux.conf
  grep -q "source-file ~/.tmux/macos.conf" .tmux.conf
  grep -q "source-file ~/.tmux/linux.conf" .tmux.conf
  grep -q 'dotfiles_platform' shell/bash/profile.bash
  grep -q 'shell/bash/common.bash' shell/bash/profile.bash
  grep -q 'shell/bash/macos.bash' shell/bash/profile.bash
  grep -q 'shell/bash/linux.bash' shell/bash/profile.bash
  grep -q 'shell/zsh/path/common.zsh' shell/zsh/path.zsh
  grep -q 'shell/zsh/path/macos.zsh' shell/zsh/path.zsh
  grep -q 'shell/zsh/path/linux.zsh' shell/zsh/path.zsh
  grep -q 'shell/zsh/platform/common.zsh' shell/zsh/platform.zsh
  grep -q 'shell/zsh/platform/macos.zsh' shell/zsh/platform.zsh
  grep -q 'shell/zsh/platform/linux.zsh' shell/zsh/platform.zsh
  grep -q 'shell/zsh/plugins/common.zsh' shell/zsh/plugins.zsh
  grep -q 'shell/zsh/plugins/macos.zsh' shell/zsh/plugins.zsh
  grep -q 'shell/zsh/plugins/linux.zsh' shell/zsh/plugins.zsh

  for module in "${modules[@]}"; do
    [ -f "$module" ] || { echo "Missing shell module: $module"; false; }
  done
}

@test "install.sh uses a centralized link spec builder" {
  grep -q "build_link_specs()" install.sh
  grep -q "ensure_symlink()" install.sh
  grep -q 'link_specs=(' install.sh
}
