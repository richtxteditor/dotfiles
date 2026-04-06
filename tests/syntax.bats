#!/usr/bin/env bats

@test "shellcheck passes on install.sh" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck is not installed"
  fi
  run shellcheck ./install.sh
  [ "$status" -eq 0 ]
}

@test "shellcheck passes on test.sh" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck is not installed"
  fi
  run shellcheck ./test.sh
  [ "$status" -eq 0 ]
}

@test "zshrc passes syntax check" {
  if ! command -v zsh &> /dev/null; then
    skip "zsh is not installed"
  fi
  run zsh -n .zshrc
  [ "$status" -eq 0 ]
}

@test ".fzf.zsh passes syntax check" {
  if ! command -v zsh &> /dev/null; then
    skip "zsh is not installed"
  fi
  run zsh -n .fzf.zsh
  [ "$status" -eq 0 ]
}

@test "bash_profile passes syntax check" {
  run bash -n .bash_profile
  [ "$status" -eq 0 ]
}

@test "shared shell modules pass bash syntax check" {
  run bash -n shell/shared/platform.sh shell/bash/profile.bash
  [ "$status" -eq 0 ]
}

@test "zsh shell modules pass syntax check" {
  run bash -c 'find shell/zsh -name "*.zsh" -exec zsh -n {} \;'
  [ "$status" -eq 0 ]
}

@test "tmux.conf passes syntax check" {
  if ! command -v tmux &> /dev/null; then
    skip "tmux is not installed"
  fi
  # Start a temporary tmux server with the config to check for parse errors
  local socket="bats_tmux_$$"
  run tmux -L "$socket" -f .tmux.conf start-server \; kill-server
  [ "$status" -eq 0 ]
}

@test "all Neovim lua files have valid syntax" {
  if ! command -v luac &> /dev/null; then
    skip "luac is not installed (install lua or luajit)"
  fi
  run bash -c 'find nvim -name "*.lua" -not -path "*/python-venv/*" -exec luac -p {} \;'
  [ "$status" -eq 0 ]
}
