#!/usr/bin/env bats

setup() {
  export ZDOTDIR="$BATS_TEST_TMPDIR"
  mkdir -p "$BATS_TEST_TMPDIR/.oh-my-zsh"
  touch "$BATS_TEST_TMPDIR/.oh-my-zsh/oh-my-zsh.sh"
  export HOME="$BATS_TEST_TMPDIR"
  export APPLE_INTERFACE_STYLE="Light"
}

# Helper: source .zshrc capturing stderr separately, fail on real errors
# Filters expected warnings from optional tools not being installed
source_zshrc_cmd() {
  local cmd="$1"
  zsh -c "
    source .zshrc 2>$BATS_TEST_TMPDIR/zshrc_stderr
    $cmd
  "
}

@test "zshrc sources without fatal errors" {
  run zsh -c "source .zshrc 2>$BATS_TEST_TMPDIR/zshrc_stderr; echo ok"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
  # Check stderr for real errors (not 'command not found' for optional tools)
  if [ -f "$BATS_TEST_TMPDIR/zshrc_stderr" ]; then
    run grep -iE '(error:|fatal:|segfault|panic)' "$BATS_TEST_TMPDIR/zshrc_stderr"
    [ "$status" -eq 1 ]  # grep should find nothing (exit 1 = no match)
  fi
}

@test "zshrc sets basic environment variables" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$EDITOR"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [ "$output" = "nvim" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$VISUAL"
  [ -n "$output" ]
  [ "$output" = "nvim" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$LANG"
  [ -n "$output" ]
  [ "$output" = "en_US.UTF-8" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$HISTSIZE"
  [ -n "$output" ]
  [ "$output" = "50000" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$SAVEHIST"
  [ -n "$output" ]
  [ "$output" = "50000" ]
}

@test "zshrc creates expected aliases" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias cat"
  [ "$output" = "cat=bat" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias ls"
  [[ "$output" == *"eza"* ]]
  [[ "$output" == *"--icons"* ]]
  [[ "$output" == *"--git"* ]]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias lg"
  [ "$output" = "lg=lazygit" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias gs"
  [ "$output" = "gs='git status -sb'" ]

  # Safety aliases
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias rm"
  [ "$output" = "rm='rm -i'" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias cp"
  [ "$output" = "cp='cp -i'" ]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias mv"
  [ "$output" = "mv='mv -i'" ]

  # Zoxide alias
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; alias cd"
  [ "$output" = "cd=z" ]
}

@test "zshrc loads custom functions" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; type mkcd"
  [[ "$output" == *"mkcd is a shell function"* ]]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; type ta"
  [[ "$output" == *"ta is a shell function"* ]]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; type _noarg_hl"
  [[ "$output" == *"_noarg_hl is a shell function"* ]]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; type nom"
  [[ "$output" == *"nom is a shell function"* ]]

  run zsh -c "source .zshrc 2>/tmp/zshrc_err; type gemini"
  [[ "$output" == *"gemini is a shell function"* ]]
}

@test "bbu fails clearly when brew is unavailable" {
  run zsh -c "DOTFILES_PLATFORM=linux source .zshrc 2>/tmp/zshrc_err; unfunction brew 2>/dev/null || true; bbu"
  [ "$status" -eq 1 ]
  [ "$output" = "brew not installed" ]
}

@test "zshrc properly configures lazy-loaded NVM" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; which node"
  [ -n "$output" ]
  [[ "$output" == *"node ()"* ]]
  [[ "$output" == *"load_nvm"* ]]
}

@test "zshrc path contains basic directories" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; echo \$PATH"
  [ -n "$output" ]
  [[ "$output" == *".local/bin"* ]]

  run zsh -c "DOTFILES_PLATFORM=macos source .zshrc 2>/tmp/zshrc_err; echo \$PATH"
  [[ "$output" == *"/opt/homebrew/bin"* ]]

  run zsh -c "DOTFILES_PLATFORM=linux source .zshrc 2>/tmp/zshrc_err; echo \$PATH"
  [[ "$output" != *"/opt/homebrew/bin"* ]]
}

@test "zshrc loads platform-specific plugins" {
  run zsh -c "DOTFILES_PLATFORM=macos source .zshrc 2>/tmp/zshrc_err; print -l -- \$plugins"
  [[ "$output" == *"brew"* ]]
  [[ "$output" == *"macos"* ]]

  run zsh -c "DOTFILES_PLATFORM=linux source .zshrc 2>/tmp/zshrc_err; print -l -- \$plugins"
  [[ "$output" == *"sudo"* ]]
  [[ "$output" != *"macos"* ]]
}

@test "zshrc remains a thin entrypoint" {
  local line_count
  line_count=$(wc -l < .zshrc | tr -d ' ')
  [ "$line_count" -le 20 ]

  run grep -c '^source "\$DOTFILES_ROOT/shell/zsh/' .zshrc
  [ "$status" -eq 0 ]
  [ "$output" -ge 8 ]
}

@test "mkcd creates directory and changes into it" {
  local testdir="$BATS_TEST_TMPDIR/mkcd_test_dir"
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; mkcd '$testdir'; printf 'PWD:%s\n' \"\$PWD\""
  [ "$status" -eq 0 ]
  [ -d "$testdir" ]
  [[ "$output" == *"PWD:$testdir"* ]]
}

@test "_noarg_hl passes through exit code of wrapped command" {
  # Create a command that exits with code 42
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/failcmd" <<'EOF'
#!/bin/bash
exit 42
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/failcmd"

  # _noarg_hl with no args should pipe through bat; if bat not available
  # or not a tty, it falls through to command directly
  run zsh -c "export PATH='$BATS_TEST_TMPDIR/bin:\$PATH'; source .zshrc 2>/tmp/zshrc_err; _noarg_hl failcmd"
  [ "$status" -eq 42 ]
}

@test "_noarg_hl passes through when args are given" {
  run zsh -c "source .zshrc 2>/tmp/zshrc_err; _noarg_hl echo hello world"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}

@test "NVM lazy-load does not shadow existing aliases" {
  # Pre-define an alias for node, then source zshrc — the guard should skip it
  run zsh -c "alias node='echo aliased'; source .zshrc 2>/tmp/zshrc_err; alias node"
  [ "$status" -eq 0 ]
  [[ "$output" == *"='echo aliased'"* ]]
}
