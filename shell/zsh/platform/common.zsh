if [[ -z "${APPLE_INTERFACE_STYLE:-}" ]]; then
  export APPLE_INTERFACE_STYLE="$(dotfiles_read_interface_style)"
fi

export BAT_THEME="$(dotfiles_bat_theme "$APPLE_INTERFACE_STYLE")"
