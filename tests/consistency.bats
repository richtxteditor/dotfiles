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

@test "all files referenced in install.sh files variable exist in repo" {
  local files_val
  files_val=$(grep '^files=' install.sh | sed 's/^files="//' | sed 's/".*$//')
  [ -n "$files_val" ]

  for f in $files_val; do
    [ -e "$f" ] || { echo "Missing file referenced in install.sh: $f"; false; }
  done
}

@test "all files referenced in install.sh config_files variable exist in repo" {
  local config_val
  config_val=$(grep '^config_files=' install.sh | sed 's/^config_files="//' | sed 's/".*$//')
  [ -n "$config_val" ]

  for f in $config_val; do
    [ -e "$f" ] || { echo "Missing config referenced in install.sh: $f"; false; }
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

@test "install.sh files and config_files have no duplicates" {
  local files_val config_val
  files_val=$(grep '^files=' install.sh | sed 's/^files="//' | sed 's/".*$//')
  config_val=$(grep '^config_files=' install.sh | sed 's/^config_files="//' | sed 's/".*$//')

  # Check for duplicates within files
  local dupes
  dupes=$(echo "$files_val" | tr ' ' '\n' | sort | uniq -d)
  [ -z "$dupes" ] || { echo "Duplicate in files: $dupes"; false; }

  # Check for duplicates within config_files
  dupes=$(echo "$config_val" | tr ' ' '\n' | sort | uniq -d)
  [ -z "$dupes" ] || { echo "Duplicate in config_files: $dupes"; false; }

  # Check for overlap between files and config_files
  local overlap
  overlap=$(echo "$files_val $config_val" | tr ' ' '\n' | sort | uniq -d)
  [ -z "$overlap" ] || { echo "Overlap between files and config_files: $overlap"; false; }
}
