#!/bin/bash
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

# --- Safety First ---
set -e # Exit immediately if a command exits with a non-zero status

# --- Helper Functions ---
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
        else
            echo "LLDB is already installed."
        fi
    fi
}

# --- Variables ---
dir=$(cd "$(dirname "$0")" && pwd)           # Dotfiles directory
timestamp=$(date +%Y%m%d_%H%M%S)             # Current timestamp
olddir=~/dotfiles_backup_$timestamp          # Backup directory with timestamp
files="zshrc tmux.conf Brewfile"             # Files to symlink in homedir
config_files="nvim"                          # Folders to symlink in .config

# --- User Confirmation ---
echo "--------------------------------------------------"
echo "This script will:"
echo "1. Install Homebrew (if missing)."
echo "2. Install dependencies via 'brew bundle'."
echo "3. Backup existing dotfiles to $olddir."
echo "4. Create symlinks for zsh, tmux, and nvim."
echo "--------------------------------------------------"
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# --- Pre-run setup ---
echo "Creating backup directory at $olddir"
mkdir -p "$olddir"
echo "Ensuring .config directory exists"
mkdir -p ~/.config

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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Linux (Standard Linuxbrew location)
    if [[ "$(uname)" == "Linux" ]]; then
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

# --- Install Dependencies ---
echo "Installing core dependencies from Brewfile..."
brew bundle --file="$dir/Brewfile"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Detected macOS. Installing Mac-specific apps from Brewfile.mac..."
    brew bundle --file="$dir/Brewfile.mac"
fi

# --- Dependency Checks ---
echo "Checking for required dependencies..."
check_and_install_lldb

# --- Symlink files in home directory ---
for file in $files; do
    source_file="$dir/$file"
    target_link=~/.$file

    # If the target exists AND is not a symlink, back it up.
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "Backing up existing $target_link to $olddir"
        mv "$target_link" "$olddir/"
    fi

    # If the symlink doesn't already point to our source, create it.
    if [ "$(readlink "$target_link")" != "$source_file" ]; then
        echo "Creating symlink for $file in home directory."
        ln -sf "$source_file" "$target_link"
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
        mv "$target_link" "$olddir/"
    fi

    # If the symlink doesn't already point to our source, create it.
    if [ "$(readlink "$target_link")" != "$source_file" ]; then
        echo "Creating symlink for $file in ~/.config directory."
        ln -sf "$source_file" "$target_link"
    else
        echo "Symlink for $file is already correctly set up."
    fi
done

echo "Dotfiles installation complete!"
echo "If you saw any errors, your original files are safe in $olddir"