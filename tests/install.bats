#!/usr/bin/env bats

@test "install.sh runs in dry-run mode without failing" {
  run ./install.sh --dry-run
  [ "$status" -eq 0 ]
  
  # Check if dry run message is output
  [[ "$output" == *"Running in dry-run mode"* ]]
}

@test "install.sh detects LLDB check on macOS (if applicable)" {
  # The LLDB check in install.sh issues a warning if lldb is missing, 
  # but in dry-run it should safely handle it and return 0.
  run ./install.sh --dry-run
  [ "$status" -eq 0 ]
}