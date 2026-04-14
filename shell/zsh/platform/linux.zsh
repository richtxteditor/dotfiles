(( $+aliases[update] )) && unalias update

function update {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Ubuntu-focused setup: apt-get not found."
    return 1
  fi

  sudo apt-get update && sudo apt-get upgrade -y
  if command -v omz >/dev/null 2>&1; then
    omz update
  fi
  echo "Updates complete."
}
