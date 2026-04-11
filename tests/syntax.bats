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

@test "shellcheck passes on ci smoke install script" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck is not installed"
  fi
  run shellcheck ./scripts/ci-smoke-install.sh
  [ "$status" -eq 0 ]
}

@test "zshrc passes syntax check" {
  if ! command -v zsh &> /dev/null; then
    skip "zsh is not installed"
  fi
  run zsh -n .zshrc platforms/macos/.zshrc platforms/ubuntu/.zshrc
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
  run bash -n .bash_profile platforms/macos/.bash_profile platforms/ubuntu/.bash_profile
  [ "$status" -eq 0 ]
}

@test "ci smoke install script passes bash syntax check" {
  run bash -n scripts/ci-smoke-install.sh
  [ "$status" -eq 0 ]
}

@test "shared shell modules pass bash syntax check" {
  run bash -n shell/shared/platform.sh shell/bash/profile.bash shell/bash/common.bash shell/bash/macos.bash shell/bash/linux.bash
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

  local tmux_home="$BATS_TEST_TMPDIR/tmux-home"
  mkdir -p "$tmux_home/.tmux"
  ln -snf "$PWD/tmux/common.conf" "$tmux_home/.tmux/common.conf"
  ln -snf "$PWD/tmux/macos.conf" "$tmux_home/.tmux/macos.conf"
  ln -snf "$PWD/tmux/linux.conf" "$tmux_home/.tmux/linux.conf"
  local tmux_tmpdir
  tmux_tmpdir="$(mktemp -d /tmp/dotfiles-tmux.XXXXXX)"

  # Start a temporary tmux server with the installed layout to check for parse errors
  local socket="bats_tmux_$$"
  run env HOME="$tmux_home" TMUX_TMPDIR="$tmux_tmpdir" tmux -L "$socket" -f .tmux.conf start-server \; kill-server
  if [ "$status" -ne 0 ] && [[ "$output" == *"Operation not permitted"* ]]; then
    skip "tmux socket creation blocked by sandbox"
  fi
  [ "$status" -eq 0 ]
}

@test "all Neovim lua files have valid syntax" {
  if ! command -v luac &> /dev/null; then
    skip "luac is not installed (install lua or luajit)"
  fi
  run bash -c 'find nvim -name "*.lua" -not -path "*/python-venv/*" -exec luac -p {} \;'
  [ "$status" -eq 0 ]
}
