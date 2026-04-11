#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR"
}

@test "bash_profile loads shared environment" {
  run bash -lc 'source ./.bash_profile; printf "%s\n%s\n%s\n" "$EDITOR" "$VISUAL" "$LANG"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvim"* ]]
  [[ "$output" == *"en_US.UTF-8"* ]]
}

@test "bash_profile loads macOS-specific path and aliases" {
  run env DOTFILES_PLATFORM=macos bash -lc 'source ./.bash_profile; printf "%s\n" "$PATH"; alias icloud; type update'
  [ "$status" -eq 0 ]
  [[ "$output" == *"/opt/homebrew/bin"* ]]
  [[ "$output" == *"icloud="* ]]
  [[ "$output" == *"update is a function"* ]]
}

@test "bash_profile loads Linux-specific path and update function" {
  run env DOTFILES_PLATFORM=linux bash -lc 'source ./.bash_profile; printf "%s\n" "$PATH"; type update'
  [ "$status" -eq 0 ]
  [[ "$output" != *"/opt/homebrew/bin"* ]]
  [[ "$output" == *".local/bin"* ]]
  [[ "$output" == *"update is a function"* ]]
}
