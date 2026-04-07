if [[ -z "${APPLE_INTERFACE_STYLE:-}" ]]; then
  export APPLE_INTERFACE_STYLE="$(dotfiles_read_interface_style)"
fi

export BAT_THEME="$(dotfiles_bat_theme "$APPLE_INTERFACE_STYLE")"

if dotfiles_is_macos; then
  alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; omz update; echo "Updates complete."'
  alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
else
  alias update='brew update; brew upgrade; brew cleanup; omz update; echo "Updates complete."'
fi
