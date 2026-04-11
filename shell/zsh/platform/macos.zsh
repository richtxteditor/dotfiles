update() {
  sudo softwareupdate -i -a
  brew update
  brew upgrade
  brew cleanup
  if command -v omz >/dev/null 2>&1; then
    omz update
  fi
  echo "Updates complete."
}

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
