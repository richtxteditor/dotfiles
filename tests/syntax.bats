#!/usr/bin/env bats

@test "shellcheck passes on install.sh" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck is not installed"
  fi
  run shellcheck ./install.sh
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

@test "Neovim lua files have valid syntax" {
  if ! command -v luac &> /dev/null; then
    skip "luac is not installed (install lua or luajit)"
  fi
  run bash -c 'find nvim/lua -name "*.lua" -exec luac -p {} \;'
  [ "$status" -eq 0 ]
}