#!/bin/bash
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

# Variables
dir=~/dotfiles          # Dotfiles directory
olddir=~/dotfiles_old   # Old dotfiles backup directory
files="zshrc tmux.conf Brewfile" # list of files/folders to symlink in homedir
config_files="nvim"     # list of files/folders to symlink in .config

# Create dotfiles_old in homedir
echo "Creating backup directory for existing dotfiles at $olddir"
mkdir -p $olddir

# Change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir

# Move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
    echo "Backing up existing ~/.$file to $olddir"
    mv -f ~/.$file $olddir/
    echo "Creating symlink for $file in home directory."
    ln -s $dir/$file ~/.$file
done

# Handle .config files
for file in $config_files; do
    echo "Backing up existing ~/.config/$file to $olddir"
    mv -f ~/.config/$file $olddir/
    echo "Creating symlink for $file in ~/.config directory."
    ln -s $dir/$file ~/.config/$file
done

echo "Dotfiles installation complete."
