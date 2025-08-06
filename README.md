# My Personal Dotfiles

![Shell](https://img.shields.io/badge/shell-Zsh-blue.svg)
![Editor](https://img.shields.io/badge/editor-Neovim-green.svg)
![Terminal](https://img.shields.io/badge/terminal-tmux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

This repository contains my personal configuration files for my development environment on macOS. The setup is managed by Git, with configurations symlinked into their proper locations.

The core philosophy is to create a consistent, portable, and highly efficient environment that can be quickly deployed on any new machine.

---

## 🚀 Quick Start on a New Machine

Setting up a new macOS machine is designed to be as automated as possible.

1.  **Clone the Repository:**
    Clone this repository into your home directory.

    ```bash
    git clone https://github.com/your-username/dotfiles.git ~/dotfiles
    ```

2.  **Run the Installation Script:**
    The `install.sh` script will back up any existing dotfiles and create the necessary symbolic links.

    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

3.  **Install Essential Tools:**
    The configurations rely on several tools managed by Homebrew. Run this command to install them.
    
    ```bash
    # This is a placeholder. You should create a Brewfile to automate this.
    # See the "Package Management" section below for instructions.
    brew install neovim tmux pyenv zsh-syntax-highlighting zsh-autosuggestions ... 
    ```

4.  **Install Neovim & Tmux Plugins:**
    *   **Neovim:** Open `nvim` and the `lazy.nvim` plugin manager will automatically install all configured plugins.
    *   **Tmux:** Start `tmux` and press **`Prefix` + `I`** (`Ctrl+a` then `I`) to have TPM install all plugins.

---

## ✨ What's Inside?

This repository manages the configuration for the following core components of my workflow.

### 🐚 Shell: Zsh + Oh My Zsh

*   **Framework:** [Oh My Zsh](https://ohmyz.sh/) for plugin and theme management.
*   **Prompt:** `dpoggi` theme for a clean, informative Git-aware prompt.
*   **Key Plugins:**
    *   `zsh-syntax-highlighting`: Provides real-time syntax highlighting for commands.
    *   `zsh-autosuggestions`: Suggests commands based on history.
    *   `z`: Allows for rapid directory jumping based on frequency and recency.
*   **Configuration File:** `zshrc` (symlinked to `~/.zshrc`)

###  multiplexer: Tmux

*   **Prefix Key:** `Ctrl+a` (ergonomic alternative to `Ctrl+b`).
*   **Key Features:**
    *   Vim-style keybindings for pane navigation (`hjkl`) and copy mode.
    *   Mouse support enabled for scrolling and selection.
    *   Session persistence across reboots via `tmux-resurrect` and `tmux-continuum`.
*   **Plugins:** Managed by [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm).
*   **Configuration File:** `tmux.conf` (symlinked to `~/.tmux.conf`)

### 📝 Editor: Neovim

A modern, Lua-based configuration designed for speed and extensibility.

*   **Plugin Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) for fast, declarative plugin management.
*   **Core Experience:**
    *   **LSP:** `nvim-lspconfig` with `mason.nvim` for automatic installation of language servers (Python, Lua, JS/TS, etc.).
    *   **Autocompletion:** `nvim-cmp` for a powerful completion engine.
    *   **Fuzzy Finding:** `Telescope.nvim` for finding files, buffers, and grepping through the project.
    *   **Syntax Highlighting:** `nvim-treesitter` for fast and accurate highlighting.
*   **Theme:** Kanagawa with automatic light/dark mode switching based on the macOS theme.
*   **Configuration Directory:** `nvim/` (symlinked to `~/.config/nvim/`)

### 📄 Cheat Sheets

This repository also contains my personal command reference sheets.

*   [Neovim Cheat Sheet](./cheat-sheets/neovim.md)
*   [Tmux & Zsh Cheat Sheet](./cheat-sheets/tmux-zsh.md)

---

## 📦 Package Management with Brewfile

To fully automate the setup, this repository uses a `Brewfile` to manage Homebrew packages.

**On a new machine, after cloning the dotfiles and installing Homebrew, run:**

```bash
brew bundle --global
