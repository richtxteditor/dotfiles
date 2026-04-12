#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config" "$TEST_HOME/.cargo/bin" "$TEST_HOME/.local/bin"
}

make_mock_repo() {
  local repo="$1"
  local platform_dir="$2"
  local bin_dir="${3:-}"
  mkdir -p "$repo/scripts" "$repo/platforms/ubuntu" "$repo/platforms/macos"

  cp "$BATS_TEST_DIRNAME/../scripts/ci-smoke-install.sh" "$repo/scripts/ci-smoke-install.sh"

  : > "$repo/platforms/ubuntu/.zshrc"
  : > "$repo/platforms/ubuntu/.bash_profile"
  : > "$repo/platforms/ubuntu/starship.toml"
  : > "$repo/platforms/macos/.zshrc"
  : > "$repo/platforms/macos/.bash_profile"
  : > "$repo/platforms/macos/starship.toml"

  cat > "$repo/install.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "\${*:-<none>}" >> "$repo/install.log"
mkdir -p "$HOME/.config"
ln -snf "$repo/platforms/$platform_dir/.zshrc" "$HOME/.zshrc"
ln -snf "$repo/platforms/$platform_dir/.bash_profile" "$HOME/.bash_profile"
ln -snf "$repo/platforms/$platform_dir/starship.toml" "$HOME/.config/starship.toml"
ln -snf "$repo/.tmux.conf" "$HOME/.tmux.conf"
touch "$repo/.tmux.conf"
if [ -n "$bin_dir" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -snf "$bin_dir/nvim" "$HOME/.local/bin/nvim"
fi
EOF
  chmod +x "$repo/install.sh"
}

make_mock_bin() {
  local bin_dir="$1"
  local git_status_output="${2:-}"
  mkdir -p "$bin_dir"

  for cmd in tree-sitter node npm ruby go php composer javac luarocks brew lua; do
    cat > "$bin_dir/$cmd" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$bin_dir/$cmd"
  done

  cat > "$bin_dir/zsh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$bin_dir/zsh"

  cat > "$bin_dir/tmux" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$bin_dir/tmux"

  cat > "$bin_dir/nvim" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then
  echo "NVIM v0.12.1"
  exit 0
fi
exit 0
EOF
  chmod +x "$bin_dir/nvim"

  cat > "$bin_dir/git" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "$bin_dir/git.log"
if [ "\${1:-}" = "status" ] && [ "\${2:-}" = "--short" ]; then
  printf '%s' "$git_status_output"
fi
exit 0
EOF
  chmod +x "$bin_dir/git"
}

@test "ci smoke install runs Linux flow, startup smokes, and clean check" {
  local repo="$BATS_TEST_TMPDIR/repo-linux"
  local bin_dir="$BATS_TEST_TMPDIR/bin-linux"
  make_mock_bin "$bin_dir"
  make_mock_repo "$repo" "ubuntu" "$bin_dir"

  run env HOME="$HOME" PATH="$bin_dir:$PATH" bash "$repo/scripts/ci-smoke-install.sh" linux
  [ "$status" -eq 0 ]

  run cat "$repo/install.log"
  [ "$status" -eq 0 ]
  [ "$output" = $'<none>\n--skip-deps' ]

  [ "$(readlink "$HOME/.zshrc")" = "$repo/platforms/ubuntu/.zshrc" ]
  [ "$(readlink "$HOME/.bash_profile")" = "$repo/platforms/ubuntu/.bash_profile" ]
  [ "$(readlink "$HOME/.config/starship.toml")" = "$repo/platforms/ubuntu/starship.toml" ]

  run cat "$bin_dir/git.log"
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --exit-code"* ]]
  [[ "$output" == *"status --short"* ]]
}

@test "ci smoke install runs macOS skip-deps flow twice" {
  local repo="$BATS_TEST_TMPDIR/repo-macos-skip"
  local bin_dir="$BATS_TEST_TMPDIR/bin-macos-skip"
  make_mock_bin "$bin_dir"
  make_mock_repo "$repo" "macos" "$bin_dir"

  run env HOME="$HOME" PATH="$bin_dir:$PATH" bash "$repo/scripts/ci-smoke-install.sh" macos skip-deps
  [ "$status" -eq 0 ]

  run cat "$repo/install.log"
  [ "$status" -eq 0 ]
  [ "$output" = $'--skip-deps\n--skip-deps' ]

  [ "$(readlink "$HOME/.zshrc")" = "$repo/platforms/macos/.zshrc" ]
  [ "$(readlink "$HOME/.bash_profile")" = "$repo/platforms/macos/.bash_profile" ]
  [ "$(readlink "$HOME/.config/starship.toml")" = "$repo/platforms/macos/starship.toml" ]
}

@test "ci smoke install runs macOS full then skip-deps" {
  local repo="$BATS_TEST_TMPDIR/repo-macos-full"
  local bin_dir="$BATS_TEST_TMPDIR/bin-macos-full"
  make_mock_bin "$bin_dir"
  make_mock_repo "$repo" "macos" "$bin_dir"

  run env HOME="$HOME" PATH="$bin_dir:$PATH" bash "$repo/scripts/ci-smoke-install.sh" macos full
  [ "$status" -eq 0 ]

  run cat "$repo/install.log"
  [ "$status" -eq 0 ]
  [ "$output" = $'<none>\n--skip-deps' ]
}

@test "ci smoke install fails on unknown platform argument" {
  local repo="$BATS_TEST_TMPDIR/repo-bad-platform"
  local bin_dir="$BATS_TEST_TMPDIR/bin-bad-platform"
  make_mock_bin "$bin_dir"
  make_mock_repo "$repo" "ubuntu" "$bin_dir"

  run env HOME="$HOME" PATH="$bin_dir:$PATH" bash "$repo/scripts/ci-smoke-install.sh" windows
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown platform argument: windows"* ]]
}

@test "ci smoke install fails on unknown macOS mode" {
  local repo="$BATS_TEST_TMPDIR/repo-bad-mode"
  local bin_dir="$BATS_TEST_TMPDIR/bin-bad-mode"
  make_mock_bin "$bin_dir"
  make_mock_repo "$repo" "macos" "$bin_dir"

  run env HOME="$HOME" PATH="$bin_dir:$PATH" bash "$repo/scripts/ci-smoke-install.sh" macos weird
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown macOS install mode: weird"* ]]
}
