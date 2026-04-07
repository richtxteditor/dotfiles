#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$dir/shell/shared/platform.sh"

DRY_RUN=""
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
        esac
    done
}

confirm_proceed() {
    echo "--------------------------------------------------"
    echo "This script will:"
    echo "1. Install Homebrew (if missing)."
    echo "2. Install dependencies via 'brew bundle'."
    echo "3. Backup existing dotfiles to $olddir."
    echo "4. Create symlinks for zsh, tmux, nvim, etc."
    echo "5. Install Tmux Plugin Manager (TPM)."
    echo "--------------------------------------------------"

    if [[ -n "$DRY_RUN" ]]; then
        echo "Running in dry-run mode (no changes will be made)."
        return
    fi

    read -r -n 1 -p "Do you want to proceed? (y/n) " REPLY
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

    if dotfiles_is_linux; then
        if [[ -d /home/linuxbrew/.linuxbrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
            else
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            fi
        fi
        if [[ -d "$HOME/.linuxbrew" ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(~/.linuxbrew/bin/brew shellenv)\""
            else
                eval "$(~/.linuxbrew/bin/brew shellenv)"
            fi
        fi
    fi
}

ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
        return
    fi

    echo "Homebrew not found. Installing..."
    if dotfiles_is_linux && ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl is required to install Homebrew."
        exit 1
    fi

    run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    configure_brew_shellenv
}

install_dependencies() {
    echo "Installing core dependencies from Brewfile..."
    run_cmd brew bundle --file="$dir/Brewfile"
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

build_link_specs() {
    link_specs=(
        ".zshrc|$HOME/.zshrc|.zshrc in home directory"
        ".tmux.conf|$HOME/.tmux.conf|.tmux.conf in home directory"
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
        add_link_spec "ghostty/config" "$ghostty_target" "Ghostty config"
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
    install_tpm
    build_link_specs
    install_links
    install_pynvim_provider
    echo "Dotfiles installation complete!"
    echo "If you saw any errors, your original files are safe in $olddir"
}

main "$@"
