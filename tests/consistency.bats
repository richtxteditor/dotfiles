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
    "ghostty/config"
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

@test "nvim init.lua entry point exists" {
  [ -f "nvim/init.lua" ]

  # Verify it requires the expected core modules
  grep -q "require.*core.lazy" nvim/init.lua
  grep -q "require.*core.options" nvim/init.lua
  grep -q "require.*core.keymaps" nvim/init.lua
}

@test "every lua file required by init.lua exists" {
  # init.lua requires core.lazy, core.options, core.keymaps
  [ -f "nvim/lua/core/lazy.lua" ]
  [ -f "nvim/lua/core/options.lua" ]
  [ -f "nvim/lua/core/keymaps.lua" ]
}

@test "shell entrypoints source modular shell files" {
  local modules=(
    "shell/shared/platform.sh"
    "shell/bash/profile.bash"
    "shell/zsh/path.zsh"
    "shell/zsh/environment.zsh"
    "shell/zsh/platform.zsh"
    "shell/zsh/plugins.zsh"
    "shell/zsh/options.zsh"
    "shell/zsh/aliases.zsh"
    "shell/zsh/functions.zsh"
    "shell/zsh/integrations.zsh"
    "shell/zsh/lang-managers.zsh"
  )

  grep -q "shell/shared/platform.sh" .zshrc
  grep -q "shell/bash/profile.bash" .bash_profile

  for module in "${modules[@]}"; do
    [ -f "$module" ] || { echo "Missing shell module: $module"; false; }
  done
}

@test "install.sh uses a centralized link spec builder" {
  grep -q "build_link_specs()" install.sh
  grep -q "ensure_symlink()" install.sh
  grep -q 'link_specs=(' install.sh
}
