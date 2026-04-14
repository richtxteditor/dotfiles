(( $+aliases[update] )) && unalias update

function update {
  sudo softwareupdate -i -a

  if command -v brew >/dev/null 2>&1; then
    brew update && HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade && brew cleanup
  fi

  if command -v omz >/dev/null 2>&1; then
    omz update
  fi
  echo "Updates complete."
}

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
