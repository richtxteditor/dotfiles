#!/bin/bash
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

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
            # Optionally, you could exit the script here if lldb is a hard requirement
            # exit 1
        else
            echo "LLDB is already installed."
        fi
    fi
}


# Variables
dir=$(cd "$(dirname "$0")" && pwd) # Dotfiles directory
olddir=~/dotfiles_old            # Old dotfiles backup directory
files="zshrc tmux.conf Brewfile" # list of files/folders to symlink in homedir
config_files="nvim"              # list of files/folders to symlink in .config

# --- Pre-run setup ---
echo "Creating backup directory for existing dotfiles at $olddir"
mkdir -p $olddir
echo "Ensuring .config directory exists"
mkdir -p ~/.config

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
        # Use -sf to safely force link creation/overwrite
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

echo "Dotfiles installation complete."
