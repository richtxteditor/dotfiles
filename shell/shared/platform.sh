dotfiles_platform() {
    if [ -n "${DOTFILES_PLATFORM:-}" ]; then
        printf '%s\n' "$DOTFILES_PLATFORM"
        return
    fi

    case "$(uname -s)" in
        Darwin) printf '%s\n' "macos" ;;
        Linux) printf '%s\n' "linux" ;;
        *) printf '%s\n' "unknown" ;;
    esac
}

dotfiles_is_macos() {
    [ "$(dotfiles_platform)" = "macos" ]
}

dotfiles_is_linux() {
    [ "$(dotfiles_platform)" = "linux" ]
}

dotfiles_read_interface_style() {
    if [ -n "${DOTFILES_INTERFACE_STYLE:-}" ]; then
        printf '%s\n' "$DOTFILES_INTERFACE_STYLE"
        return
    fi

    if dotfiles_is_macos && command -v defaults >/dev/null 2>&1; then
        local style
        style="$(defaults read -g AppleInterfaceStyle 2>/dev/null || printf '%s' "Light")"
        if [ "$style" = "Dark" ]; then
            printf '%s\n' "Dark"
        else
            printf '%s\n' "Light"
        fi
        return
    fi

    if [ -n "${APPLE_INTERFACE_STYLE:-}" ]; then
        printf '%s\n' "$APPLE_INTERFACE_STYLE"
    else
        printf '%s\n' "Light"
    fi
}

dotfiles_bat_theme() {
    if [ "${1:-Light}" = "Dark" ]; then
        printf '%s\n' "OneHalfDark"
    else
        printf '%s\n' "OneHalfLight"
    fi
}

dotfiles_nom_config_path() {
    if dotfiles_is_linux; then
        printf '%s\n' "$HOME/.config/nom/config.yml"
    else
        printf '%s\n' "$HOME/Library/Application Support/nom/config.yml"
    fi
}

dotfiles_ghostty_config_dir() {
    if dotfiles_is_macos; then
        printf '%s\n' "$HOME/Library/Application Support/com.mitchellh.ghostty"
        return
    fi

    if dotfiles_is_linux; then
        printf '%s\n' "$HOME/.config/ghostty"
        return
    fi

    return 1
}

dotfiles_ghostty_config_target() {
    local config_dir
    config_dir="$(dotfiles_ghostty_config_dir)" || return 1
    printf '%s\n' "$config_dir/config"
}
