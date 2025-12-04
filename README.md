# Dotfiles

![Shell](https://img.shields.io/badge/shell-Zsh-blue.svg)
![Editor](https://img.shields.io/badge/editor-Neovim-green.svg)
![Terminal](https://img.shields.io/badge/terminal-tmux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

This repository contains configuration files for a high-performance, terminal-centric development environment on macOS. The setup integrates Zsh, Tmux, and Neovim into a unified workspace, prioritizing keyboard-driven navigation, fast startup times, and session persistence.

---

## Installation

Follow these steps to deploy the environment on a fresh macOS installation.

### Phase 1: Manual Bootstrap

Perform these steps manually to prepare the system.

1. **Install Homebrew:**
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. **Configure SSH for GitHub:**
    Generate an SSH key and add it to your GitHub account settings to enable repository cloning.
    ```bash
    ssh-keygen -t ed25519 -C "your_email@example.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    pbcopy < ~/.ssh/id_ed25519.pub
    ```

### Phase 2: Deployment

1. **Clone Repository:**
    ```bash
    git clone git@github.com:your-username/dotfiles.git ~/dotfiles
    ```

2. **Run Installation Script:**
    This script backs up existing configurations and creates symbolic links for `.zshrc`, `.tmux.conf`, and `.config/nvim`.
    ```bash
    cd ~/dotfiles
    ./install.sh
    ```

### Phase 3: Package Installation

1. **Install Software:**
    Uses Homebrew Bundle to install core utilities (Neovim, Tmux, Lazygit, Eza, Bat, Zoxide, FZF) and fonts.
    ```bash
    brew bundle --global
    ```

2. **Reload Shell:**
    Close and reopen the terminal to initialize Zsh with the new configuration.

### Phase 4: Configuration

1. **Initialize Tmux Plugins:**
    * Start a session: `ta`
    * Install plugins: Press **Ctrl+a** then **I** (Shift+i).

2. **Initialize Neovim Plugins:**
    * Open Neovim: `nvim`
    * Wait for `lazy.nvim` to complete plugin installation.
    * Restart Neovim.

3. **Install Language Runtimes:**
    ```bash
    # Python
    pyenv install 3.12.7
    pyenv global 3.12.7

    # Node.js
    nvm install 20
    nvm alias default 20
    ```

---

## Core Utilities & Workflow

This environment utilizes modern CLI replacements to enhance standard Unix commands.

### Navigation
Neovim and Tmux are configured to share navigation contexts. Focus moves seamlessly between editor splits and terminal panes using the same keybindings.

*   **Left:** `Ctrl + h`
*   **Down:** `Ctrl + j`
*   **Up:** `Ctrl + k`
*   **Right:** `Ctrl + l`

### CLI Tools

| Tool | Description | Usage |
| :--- | :--- | :--- |
| **Zoxide** | Directory navigation replacement for `cd`. | `z <name>` jumps to the best match. |
| **Eza** | Modern replacement for `ls`. | `ls` (standard), `ll` (detailed with git status). |
| **Bat** | `cat` clone with syntax highlighting. | `cat <file>` displays file contents. |
| **Lazygit** | Terminal UI for Git operations. | `lg` (CLI) or `<leader>gg` (Neovim). |
| **FZF-Tab** | Fuzzy completion for Zsh. | Press `Tab` on commands to trigger interactive selection. |

### Research & AI
*   **Nom:** Command line RSS reader with markdown rendering.
*   **Gemini CLI:** AI assistance via command line.
*   **Error Debugging:** Pipe stderr to Gemini for analysis:
    ```bash
    python script.py 2>&1 | explain
    ```

### Session Management
*   **Attach/Create:** Run `ta` to attach to an existing session or create a new one.
*   **Persistence:** `tmux-resurrect` and `tmux-continuum` automatically save and restore session layouts, including running processes, across system restarts.

---

## Configuration Overview

### Zsh (Shell)
*   **Prompt:** Minimal, git-aware prompt indicating branch and status.
*   **Completion:** Integrated `fzf` for fuzzy file and history search.
*   **History:** `Ctrl+Space` accepts auto-suggestions.

### Tmux (Multiplexer)
*   **Prefix:** `Ctrl+a`
*   **Appearance:** Kanagawa Dragon theme with high-contrast active borders.
*   **Features:** True Color support, mouse mode enabled, system clipboard synchronization (`pbcopy`).

### Neovim (Editor)
*   **Performance:** Optimized for sub-100ms startup via `lazy.nvim`.
*   **LSP:** Full support for Go to Definition (`gd`), Hover (`K`), and Rename (`gr`).
*   **Search:** Telescope (`Space f f`) for fuzzy finding files and text.
*   **Formatting:** Auto-formatting on save configured via `conform.nvim`.

---

## Documentation

* [Neovim Cheat Sheet](./cheat-sheets/neovim.md)
* [Tmux & Zsh Cheat Sheet](./cheat-sheets/tmux-zsh.md)

---

## License

This project is licensed under the MIT License.
