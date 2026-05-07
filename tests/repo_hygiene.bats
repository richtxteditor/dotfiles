#!/usr/bin/env bats

@test "repo does not contain machine-local Finder metadata" {
  run bash -c 'find . -path ./.git -prune -o -name ".DS_Store" -print'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "repo does not carry local Neovim runtime artifacts" {
  [ ! -e "nvim/python-venv" ]
  [ ! -e "nvim/nvim" ]
}

@test "repo does not hardcode this machine's dotfiles checkout path" {
  run bash -c 'grep -R --exclude-dir=.git "[/]Users/what/Sites/dotfiles" -- .'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}
