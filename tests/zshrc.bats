#!/usr/bin/env bats

setup() {
  export ZDOTDIR="$BATS_TEST_TMPDIR"
  mkdir -p "$BATS_TEST_TMPDIR/.oh-my-zsh"
  touch "$BATS_TEST_TMPDIR/.oh-my-zsh/oh-my-zsh.sh"
  export HOME="$BATS_TEST_TMPDIR"
  cp .zshrc "$BATS_TEST_TMPDIR/.zshrc"
  touch "$BATS_TEST_TMPDIR/.fzf.zsh"
}

@test "zshrc sets basic environment variables" {
  run zsh -c 'source .zshrc 2>/dev/null; echo $EDITOR'
  [ "$status" -eq 0 ]
  [ "$output" = "nvim" ]

  run zsh -c 'source .zshrc 2>/dev/null; echo $VISUAL'
  [ "$output" = "nvim" ]

  run zsh -c 'source .zshrc 2>/dev/null; echo $LANG'
  [ "$output" = "en_US.UTF-8" ]
}

@test "zshrc creates expected aliases" {
  run zsh -c 'source .zshrc 2>/dev/null; alias cat'
  [[ "$output" == *"bat"* ]]

  run zsh -c 'source .zshrc 2>/dev/null; alias ls'
  [[ "$output" == *"eza"* ]]

  run zsh -c 'source .zshrc 2>/dev/null; alias lg'
  [[ "$output" == *"lazygit"* ]]

  run zsh -c 'source .zshrc 2>/dev/null; alias gs'
  [[ "$output" == *"git status -sb"* ]]
}

@test "zshrc loads custom functions" {
  run zsh -c 'source .zshrc 2>/dev/null; type mkcd'
  [[ "$output" == *"mkcd is a shell function"* ]]

  run zsh -c 'source .zshrc 2>/dev/null; type ta'
  [[ "$output" == *"ta is a shell function"* ]]

  run zsh -c 'source .zshrc 2>/dev/null; type _noarg_hl'
  [[ "$output" == *"_noarg_hl is a shell function"* ]]
}

@test "zshrc properly configures lazy-loaded NVM" {
  run zsh -c 'source .zshrc 2>/dev/null; which node'
  [[ "$output" == *"node ()"* ]]
  [[ "$output" == *"load_nvm"* ]]
}

@test "zshrc path contains basic directories" {
  run zsh -c 'source .zshrc 2>/dev/null; echo $PATH'
  [[ "$output" == *"/opt/homebrew/bin"* ]]
  [[ "$output" == *".local/bin"* ]]
}
