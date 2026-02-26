#!/usr/bin/env bash
# Runs the test suite for dotfiles

set -e

# Change to the root directory of the project
cd "$(dirname "$0")"

echo "Running tests..."

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed."
    echo "Please install it via 'brew install bats-core shellcheck'"
    exit 1
fi

bats tests/
