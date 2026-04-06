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
