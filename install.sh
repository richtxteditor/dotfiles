#!/bin/bash
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

# --- Safety First ---
set -e # Exit immediately if a command exits with a non-zero status

# --- Helper Functions ---
run_cmd() {
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: $*"
    else
        "$@"
    fi
}

check_and_install_lldb() {
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v lldb &> /dev/null; then
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
                return 0
            fi
            return 1
        else
            echo "LLDB is already installed."
        fi
    fi
}

# --- Args ---
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
    esac
done

# --- Variables ---
dir=$(cd "$(dirname "$0")" && pwd)           # Dotfiles directory
timestamp=$(date +%Y%m%d_%H%M%S)             # Current timestamp
olddir=~/dotfiles_backup_$timestamp          # Backup directory with timestamp
files=".zshrc .tmux.conf .bash_profile .fzf.zsh"             # Files to symlink in homedir
config_files="nvim starship.toml"            # Folders/files to symlink in .config

# --- User Confirmation ---
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
else
    read -p "Do you want to proceed? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# --- Pre-run setup ---
echo "Creating backup directory at $olddir"
run_cmd mkdir -p "$olddir"
echo "Ensuring .config directory exists"
run_cmd mkdir -p ~/.config

# --- Homebrew Setup ---
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    if [[ "$(uname)" == "Linux" ]]; then
        # Ensure curl exists on Linux
        if ! command -v curl &> /dev/null; then
            echo "Error: curl is required to install Homebrew."
            exit 1
        fi
    fi
    run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for macOS/Linux (current shell)
    if [[ "$(uname)" == "Darwin" ]]; then
        if test -d /opt/homebrew; then
            if [[ -z "$DRY_RUN" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo "DRY RUN: eval \"$(/opt/homebrew/bin/brew shellenv)\""
            fi
        elif test -d /usr/local/Homebrew; then
            if [[ -z "$DRY_RUN" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            else
                echo "DRY RUN: eval \"$(/usr/local/bin/brew shellenv)\""
            fi
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        if test -d /home/linuxbrew/.linuxbrew; then
            if [[ -z "$DRY_RUN" ]]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            else
                echo "DRY RUN: eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
            fi
        fi
        if test -d ~/.linuxbrew; then
            if [[ -z "$DRY_RUN" ]]; then
                eval "$(~/.linuxbrew/bin/brew shellenv)"
            else
                echo "DRY RUN: eval \"$(~/.linuxbrew/bin/brew shellenv)\""
            fi
        fi
    fi
else
    echo "Homebrew is already installed."
fi

# --- Install Dependencies ---
echo "Installing core dependencies from Brewfile..."
run_cmd brew bundle --file="$dir/Brewfile"

# --- Dependency Checks ---
echo "Checking for required dependencies..."
check_and_install_lldb

# --- TPM Setup ---
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installing Tmux Plugin Manager (TPM)..."
    run_cmd git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM is already installed."
fi

# --- Symlink files in home directory ---
for file in $files; do
    source_file="$dir/$file"
    target_link=~/$file

    # If the target exists AND is not a symlink, back it up.
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "Backing up existing $target_link to $olddir"
        run_cmd mv "$target_link" "$olddir/"
    fi

    # If the symlink doesn't already point to our source, create it.
    if [ -L "$target_link" ]; then
        current_link="$(readlink "$target_link")"
    else
        current_link=""
    fi
    if [ "$current_link" != "$source_file" ]; then
        echo "Creating symlink for $file in home directory."
        run_cmd ln -snf "$source_file" "$target_link"
    else
        echo "Symlink for $file is already correctly set up."
    fi
done

# --- Symlink files in .config directory ---
for file in $config_files; do
    source_file="$dir/$file"
    target_link=~/.config/$file

    # If the target exists AND is not a symlink, back it up.
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "Backing up existing $target_link to $olddir"
        run_cmd mv "$target_link" "$olddir/"
    fi

    # If the symlink doesn't already point to our source, create it.
    if [ -L "$target_link" ]; then
        current_link="$(readlink "$target_link")"
    else
        current_link=""
    fi
    if [ "$current_link" != "$source_file" ]; then
        echo "Creating symlink for $file in ~/.config directory."
        run_cmd ln -snf "$source_file" "$target_link"
    else
        echo "Symlink for $file is already correctly set up."
    fi
done

echo "Dotfiles installation complete!"
echo "If you saw any errors, your original files are safe in $olddir"
