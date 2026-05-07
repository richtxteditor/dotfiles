#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
template="$repo_root/scripts/com.user.sleep-guard.plist.template"
output="$HOME/Library/LaunchAgents/com.user.sleep-guard.plist"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "sleep-guard launchd agent is macOS-only."
    exit 1
fi

repo_root_escaped="${repo_root//\\/\\\\}"
repo_root_escaped="${repo_root_escaped//&/\\&}"

mkdir -p "$(dirname "$output")"
sed "s#__DOTFILES_REPO__#$repo_root_escaped#g" "$template" > "$output"
plutil -lint "$output"
launchctl unload "$output" >/dev/null 2>&1 || true
launchctl load "$output"
echo "Installed sleep guard LaunchAgent at $output"
