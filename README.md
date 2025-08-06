# My Personal Dotfiles

![Shell](https://img.shields.io/badge/shell-Zsh-blue.svg)
![Editor](https://img.shields.io/badge/editor-Neovim-green.svg)
![Terminal](https://img.shields.io/badge/terminal-tmux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

This repository contains my personal configuration files for my development environment on macOS. The setup is managed by Git, with configurations symlinked into their proper locations.

The core philosophy is to create a consistent, portable, and highly efficient environment that can be quickly deployed on any new machine.

---

## 🚀 Installation on a New Machine

This guide provides a complete, step-by-step process for setting up a new macOS environment from scratch using this repository.

## Phase 1: Manual Bootstrap 🥾

These steps must be performed manually on a fresh macOS installation before the automation can take over.

1. **Install Homebrew:**
    Homebrew is the package manager for macOS and the foundation of this setup. Open the default Terminal app and run the official installation script:

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. **Generate & Add SSH Key to GitHub:**
    You need to register your new machine's SSH key with GitHub to clone repositories via SSH.

    ```bash
    # 1. Generate a new SSH key
    ssh-keygen -t ed25519 -C "your_email@example.com"

    # 2. Start the ssh-agent
    eval "$(ssh-agent -s)"

    # 3. Add your key to the agent
    ssh-add ~/.ssh/id_ed25519

    # 4. Copy the public key to your clipboard
    pbcopy < ~/.ssh/id_ed25519.pub
    ```

    Now, navigate to **GitHub > Settings > SSH and GPG keys > New SSH key**, and paste the key from your clipboard.

## Phase 2: Dotfiles Deployment 👷🏽‍♂️

Now we deploy the configuration from this repository.

1. **Clone Your Dotfiles:**

    ```bash
    git clone git@github.com:your-username/dotfiles.git ~/dotfiles
    ```

2. **Run the Installation Script:**
    This script backs up any default configs and creates all the necessary symbolic links (`.zshrc`, `.tmux.conf`, `.config/nvim`, etc.).

    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

## Phase 3: Automated Installation 🧑🏽‍💻

The `Brewfile` in this repository defines every application and tool to be installed.

1. **Install All Software via Brew Bundle:**
    This command reads the symlinked `~/.Brewfile` and installs everything. This will take some time.

    ```bash
    brew bundle --global
    ```

2. **Restart Your Terminal:**
    **This is a critical step.** Close your current terminal and open a new one. This will launch Zsh with your new `.zshrc` configuration, and all your aliases and plugins will be active.

## Phase 4: First-Run Tool Configurations 🛠️

The tools are installed, but they need to set up their own internal plugins.

1. **Install Tmux Plugins:**
    * Start tmux: `ta`
    * Press **`Prefix` + `I`** (`Ctrl+a` then `Shift+i`) to have TPM install all plugins.

2. **Install Neovim Plugins:**
    * Start Neovim: `nvim`
    * `lazy.nvim` will automatically pop up and install all plugins.
    * Restart Neovim once it's finished.

3. **Install Language Versions:**
    The version managers are installed, but you need to install the specific language versions.

    ```bash
    # Example for Python
    pyenv install 3.12.7
    pyenv global 3.12.7

    # Example for Node
    nvm install 20
    nvm alias default 20
    ```

4. **Configure Git Identity:**
    Tell Git who you are on this new machine.

    ```bash
    git config --global user.name "Your Name"
    git config --global user.email "your_email@example.com"
    ```

    Your environment is now fully configured and ready to use.

---

## ✨ What's Inside?

This repository manages the configuration for the following core components of my workflow.

### 🐚 Shell: Zsh + Oh My Zsh

* **Framework:** [Oh My Zsh](https://ohmyz.sh/)
* **Prompt:** `dpoggi` theme
* **Key Plugins:** `zsh-syntax-highlighting`, `zsh-autosuggestions`, `z`
* **Configuration File:** `zshrc` (symlinked to `~/.zshrc`)

### 💻 multiplexer: Tmux

* **Prefix Key:** `Ctrl+a`
* **Key Features:** Vi-style navigation, mouse support, session persistence with `tmux-resurrect` & `tmux-continuum`.
* **Plugins:** Managed by [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm).
* **Configuration File:** `tmux.conf` (symlinked to `~/.tmux.conf`)

### 📝 Editor: Neovim

A modern, Lua-based configuration designed for speed and extensibility.

* **Plugin Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
* **Core Experience:** LSP (`mason.nvim`), Autocompletion (`nvim-cmp`), Fuzzy Finding (`Telescope.nvim`), Syntax Highlighting (`nvim-treesitter`).
* **Theme:** Kanagawa with automatic light/dark mode switching.
* **Configuration Directory:** `nvim/` (symlinked to `~/.config/nvim/`)

### 📄 Cheat Sheets

This repository also contains my personal command reference sheets.

* [Neovim Cheat Sheet](./cheat-sheets/neovim.md)
* [Tmux & Zsh Cheat Sheet](./cheat-sheets/tmux-zsh.md)

---

## 📜 License

This project is licensed under the MIT License. Feel free to use and adapt any part of this configuration for your own setup.
