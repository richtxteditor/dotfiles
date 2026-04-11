#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$dir/shell/shared/platform.sh"

DRY_RUN=""
SKIP_DEPS=""
timestamp="$(date +%Y%m%d_%H%M%S)"
olddir="$HOME/dotfiles_backup_$timestamp"
link_specs=()

run_cmd() {
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: $*"
    else
        "$@"
    fi
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run|-n) DRY_RUN=1 ;;
            --skip-deps) SKIP_DEPS=1 ;;
        esac
    done
}

platform_label() {
    case "$(dotfiles_platform)" in
        macos) printf '%s\n' "macOS" ;;
        linux) printf '%s\n' "Linux" ;;
        *) printf '%s\n' "unknown platform" ;;
    esac
}

print_linux_package_workaround() {
    echo "Linux workaround: Ubuntu-first apt install for core tools, then re-run installer."
    echo "Suggested command:"
    echo "  sudo apt-get update && sudo apt-get install -y git curl zsh tmux neovim fzf ripgrep fd-find bat xclip build-essential"
    echo "If you are not on Ubuntu or Debian, install equivalent packages manually."
}

should_manage_dependencies() {
    [[ -z "$SKIP_DEPS" ]]
}

confirm_proceed() {
    local step=1

    echo "--------------------------------------------------"
    echo "Detected platform: $(platform_label)"
    echo "This script will:"
    if should_manage_dependencies; then
        if dotfiles_is_macos; then
            echo "$step. Install Homebrew (if missing)."
            ((step++))
            echo "$step. Install dependencies via 'brew bundle'."
        elif dotfiles_is_linux; then
            echo "$step. Skip Homebrew dependency install on Linux."
            ((step++))
            echo "$step. Print Ubuntu apt workaround."
        else
            echo "$step. Skip dependency installation."
        fi
    else
        echo "$step. Skip dependency installation."
    fi
    ((step++))
    echo "$step. Backup existing dotfiles to $olddir."
    ((step++))
    echo "$step. Create symlinks for zsh, tmux, nvim, etc."
    ((step++))
    echo "$step. Set default shell to zsh when available."
    ((step++))
    echo "$step. Install Tmux Plugin Manager (TPM)."
    echo "--------------------------------------------------"

    if [[ -n "$DRY_RUN" ]]; then
        echo "Running in dry-run mode (no changes will be made)."
        return
    fi

    read -r -p "Do you want to proceed? (y/n) " REPLY
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
}

prepare_backup_dir() {
    echo "Creating backup directory at $olddir"
    run_cmd mkdir -p "$olddir"
}

check_and_install_lldb() {
    if ! dotfiles_is_macos; then
        return
    fi

    if ! command -v lldb >/dev/null 2>&1; then
        echo "---------------------------------------------------------------------"
        echo "WARNING: 'lldb' command not found."
        echo "CodeLLDB requires LLDB to be installed on your system."
        echo "Please install the Xcode Command Line Tools by running:"
        echo ""
        echo "    xcode-select --install"
        echo ""
        echo "After installation, re-run this script."
        echo "---------------------------------------------------------------------"
        if [[ -n "$DRY_RUN" ]]; then
            echo "DRY RUN: would exit due to missing LLDB."
            return
        fi
        exit 1
    fi

    echo "LLDB is already installed."
}

configure_brew_shellenv() {
    if dotfiles_is_macos; then
        if [[ -d /opt/homebrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(/opt/homebrew/bin/brew shellenv)\""
            else
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        elif [[ -d /usr/local/Homebrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(/usr/local/bin/brew shellenv)\""
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        return
    fi

}

ensure_homebrew() {
    if dotfiles_is_linux; then
        echo "Skipping Homebrew on Linux."
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
        return
    fi

    echo "Homebrew not found. Installing..."
    run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    configure_brew_shellenv
}

install_dependencies() {
    if ! should_manage_dependencies; then
        echo "Skipping dependency installation (--skip-deps)."
        return
    fi

    if dotfiles_is_linux; then
        print_linux_package_workaround
        return
    fi

    echo "Installing core dependencies from Brewfile..."
    run_cmd brew bundle --file="$dir/Brewfile"
}

ensure_default_shell_is_zsh() {
    local zsh_path="${ZSH_PATH:-}"

    if [[ -z "$DRY_RUN" && ! -t 0 ]]; then
        echo "Skipping default shell change: non-interactive session."
        return
    fi

    if [[ "${SHELL:-}" == *zsh ]]; then
        echo "Default shell already uses zsh."
        return
    fi

    if [[ -z "$zsh_path" ]]; then
        zsh_path="$(command -v zsh 2>/dev/null || true)"
    fi

    if [[ -z "$zsh_path" ]]; then
        echo "Skipping default shell change: zsh not found yet."
        return
    fi

    if [[ -f /etc/shells ]] && ! grep -qx "$zsh_path" /etc/shells; then
        echo "Skipping default shell change: $zsh_path not listed in /etc/shells."
        echo "Add it to /etc/shells, then run: chsh -s $zsh_path"
        return
    fi

    if ! command -v chsh >/dev/null 2>&1; then
        echo "Skipping default shell change: chsh not available."
        echo "Set it manually with: chsh -s $zsh_path"
        return
    fi

    echo "Setting default shell to zsh ($zsh_path)..."
    run_cmd chsh -s "$zsh_path"
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        echo "TPM is already installed."
        return
    fi

    echo "Installing Tmux Plugin Manager (TPM)..."
    run_cmd git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

add_link_spec() {
    link_specs+=("$1|$2|$3")
}

platform_source_file() {
    local macos_source="$1"
    local linux_source="$2"

    if dotfiles_is_macos; then
        printf '%s\n' "$macos_source"
        return
    fi

    if dotfiles_is_linux; then
        printf '%s\n' "$linux_source"
        return
    fi

    printf '%s\n' "$macos_source"
}

build_link_specs() {
    local tmux_source ghostty_source
    tmux_source="$(platform_source_file ".tmux.conf" ".tmux.conf")"
    ghostty_source="$(platform_source_file "ghostty/config.macos" "ghostty/config.linux")"

    link_specs=(
        ".zshrc|$HOME/.zshrc|.zshrc in home directory"
        "$tmux_source|$HOME/.tmux.conf|.tmux.conf in home directory"
        "tmux/common.conf|$HOME/.tmux/common.conf|tmux common config"
        "tmux/macos.conf|$HOME/.tmux/macos.conf|tmux macOS config"
        "tmux/linux.conf|$HOME/.tmux/linux.conf|tmux Linux config"
        ".bash_profile|$HOME/.bash_profile|.bash_profile in home directory"
        ".fzf.zsh|$HOME/.fzf.zsh|.fzf.zsh in home directory"
        ".gitconfig|$HOME/.gitconfig|.gitconfig in home directory"
        ".gitignore_global|$HOME/.gitignore_global|.gitignore_global in home directory"
        "nvim|$HOME/.config/nvim|nvim in ~/.config directory"
        "starship.toml|$HOME/.config/starship.toml|starship.toml in ~/.config directory"
        "claude/CLAUDE.md|$HOME/.claude/CLAUDE.md|Claude Code config"
    )

    local ghostty_target
    if ghostty_target="$(dotfiles_ghostty_config_target 2>/dev/null)"; then
        add_link_spec "$ghostty_source" "$ghostty_target" "Ghostty config"
    fi
}

ensure_symlink() {
    local relative_source="$1"
    local target_link="$2"
    local label="$3"
    local source_file="$dir/$relative_source"
    local target_dir current_link=""

    target_dir="$(dirname "$target_link")"
    run_cmd mkdir -p "$target_dir"

    if [[ -e "$target_link" && ! -L "$target_link" ]]; then
        echo "Backing up existing $label to $olddir"
        run_cmd mv "$target_link" "$olddir/"
    fi

    if [[ -L "$target_link" ]]; then
        current_link="$(readlink "$target_link")"
    fi

    if [[ "$current_link" != "$source_file" ]]; then
        echo "Creating symlink for $label."
        run_cmd ln -snf "$source_file" "$target_link"
    else
        echo "Symlink for $label is already correctly set up."
    fi
}

install_links() {
    local spec relative_source target_link label
    for spec in "${link_specs[@]}"; do
        IFS='|' read -r relative_source target_link label <<< "$spec"
        ensure_symlink "$relative_source" "$target_link" "$label"
    done
}

install_pynvim_provider() {
    local debugpy_pip="$HOME/.local/share/nvim/mason/packages/debugpy/venv/bin/pip"

    if [[ ! -x "$debugpy_pip" ]]; then
        echo "Note: debugpy venv not found yet. Open Neovim and let Mason install debugpy,"
        echo "then re-run this script to set up the Python provider."
        return
    fi

    if ! "$debugpy_pip" show pynvim >/dev/null 2>&1; then
        echo "Installing pynvim in debugpy venv for Neovim Python provider..."
        run_cmd "$debugpy_pip" install pynvim
    else
        echo "pynvim is already installed in debugpy venv."
    fi
}

main() {
    parse_args "$@"
    confirm_proceed
    prepare_backup_dir
    ensure_homebrew
    install_dependencies
    echo "Checking for required dependencies..."
    check_and_install_lldb
    build_link_specs
    install_links
    ensure_default_shell_is_zsh
    install_tpm
    install_pynvim_provider
    echo "Dotfiles installation complete!"
    echo "If you saw any errors, your original files are safe in $olddir"
}

main "$@"
