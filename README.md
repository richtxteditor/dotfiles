# Dotfiles

![Shell](https://img.shields.io/badge/shell-Zsh-blue.svg)
![Editor](https://img.shields.io/badge/editor-Neovim-green.svg)
![Terminal](https://img.shields.io/badge/terminal-tmux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

This repository contains configuration files for a high-performance, terminal-centric development environment on macOS and Linux. The setup integrates Zsh, Tmux, and Neovim into a unified workspace, prioritizing keyboard-driven navigation, fast startup times, and session persistence.

---

## Installation

Follow these steps to deploy the environment on a fresh macOS or Linux installation.

### Phase 1: Deployment

1. **Clone Repository:**
    ```bash
    git clone https://github.com/your-username/dotfiles.git ~/dotfiles
    ```

2. **Run Installation Script:**
    This script backs up existing configurations, creates symbolic links, installs all dependencies (Homebrew, Zsh, Neovim, etc.), and sets up the Tmux Plugin Manager (TPM).
    ```bash
    cd ~/dotfiles
    ./install.sh
    ```
    *Note: The script is safe to run. It will ask for confirmation and backup your old dotfiles to `~/dotfiles_backup_<timestamp>`.*

    **Dry run (no changes):**
    ```bash
    ./install.sh --dry-run
    ```

### Phase 2: Configuration

1. **Initialize Tmux Plugins:**
    * Start a session: `tmux` or `ta`
    * Press **Ctrl+a** then **I** (Shift+i) to install plugins.

2. **Initialize Neovim Plugins:**
    * Open Neovim: `nvim`
    * Wait for `lazy.nvim` to complete plugin installation.
    * Restart Neovim.

3. **Install Language Runtimes (Optional):**
    `nvm` is lazy-loaded for Node.js. `pyenv` and `rbenv` are installed via Homebrew but not auto-initialized.
    ```bash
    # Node.js
    nvm install 20
    nvm alias default 20
    ```

---

## Cheat Sheet & Keybindings

Below is a comprehensive guide to the tools and keybindings available in this environment.

### Neovim
*Your modal text editor.*

#### General
| Key | Action |
| :--- | :--- |
| `<Space>` | **Leader Key** |
| `<Leader>w` | Save File |
| `<Leader>q` | Quit Window |
| `<Leader>Q` | Force Quit All |
| `<Leader><Space>` | Clear Search Highlight |
| `<Leader>c` | Configuration (Dashboard) |

#### Navigation & Windows
| Key | Action |
| :--- | :--- |
| `<C-h>` | Navigate Left (Tmux/Split) |
| `<C-j>` | Navigate Down (Tmux/Split) |
| `<C-k>` | Navigate Up (Tmux/Split) |
| `<C-l>` | Navigate Right (Tmux/Split) |
| `<Leader>e` | Toggle File Explorer (NvimTree) |

#### Telescope (Finding Things)
| Key | Action |
| :--- | :--- |
| `<Leader>ff` | Find Files |
| `<Leader>fg` | Live Grep (Find Text) |
| `<Leader>fb` | Find Buffers |
| `<Leader>fh` | Find Help Tags |
| `<Leader>fo` | Find Old/Recent Files |
| `<Leader>fd` | Find Diagnostics |
| `<Leader>ft` | Find TODOs |

#### LSP (Code Intelligence)
*Available when an LSP is attached to the buffer.*

| Key | Action |
| :--- | :--- |
| `gd` | Goto Definition |
| `gr` | Goto References |
| `K` | Hover Documentation |
| `<Leader>ca` | Code Action |
| `<Leader>rn` | Rename Symbol |
| `<Leader>cf` | Code Format |
| `<Tab>` | Select Next Completion Item / Jump (Tabout) |
| `<S-Tab>` | Select Previous Completion Item |

#### Diagnostics & Trouble
| Key | Action |
| :--- | :--- |
| `<Leader>xx` | Toggle Diagnostics Panel |
| `<Leader>xw` | Toggle Workspace Diagnostics |
| `<Leader>xd` | Toggle Document Diagnostics |
| `<Leader>xL` | Toggle Location List |
| `<Leader>xQ` | Toggle Quickfix List |

#### Git
| Key | Action |
| :--- | :--- |
| `<Leader>gg` | Open LazyGit |

#### Debugging (DAP)
| Key | Action |
| :--- | :--- |
| `<F5>` | Continue / Start |
| `<F6>` | Stop / Terminate |
| `<F8>` | Step Out |
| `<F9>` | Toggle Breakpoint |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<Leader>b` | Toggle Breakpoint |
| `<Leader>dr` | Open REPL |
| `<Leader>du` | Toggle Debug UI |
| `<Leader>de` | Evaluate Expression |

#### Markdown
| Key | Action |
| :--- | :--- |
| `<Leader>mp` | Toggle Preview |
| `<Leader>ms` | Stop Preview |

#### Quality of Life (Flash & Todos)
| Key | Action |
| :--- | :--- |
| `s` | Flash Jump (Navigation) |
| `S` | Flash Treesitter Select |
| `r` | Remote Flash (Operator Pending) |
| `R` | Treesitter Search |
| `<C-s>` | Toggle Flash Search |
| `]t` | Next TODO Comment |
| `[t` | Previous TODO Comment |

---

### Tmux
*Your terminal multiplexer.*

**Prefix Key:** `Ctrl + a`

#### 1. Session Management (The "Workspaces")

Your `tmux-resurrect` plugin helps save and restore session layouts.

| Action | Keybinding / Command | Description |
| :--- | :--- | :--- |
| **Start / Attach** | `ta` (alias) | **Your entry point.** Smartly attaches to the last session or creates a new one. |
| **Fuzzy Switcher** | `Ctrl` + `j` | Opens a fuzzy search popup to switch sessions instantly (requires `fzf`). |
| **Detach Session** | `Prefix` + `d` | Detach from the current session (it keeps running). |
| **List Sessions** | `Prefix` + `s` | Show an interactive list of all sessions to switch between. |
| **Rename Session** | `Prefix` + `$` | Rename the current session. |
| **Kill Server** | `tmux kill-server` | **The "Nuke" Option.** Kills all sessions and the Tmux process itself. |

#### 2. Windows (The "Tabs")

Each window is a full-screen workspace within a session.

| Action | Keybinding |
| :--- | :--- |
| **New Window** | `Prefix` + `c` |
| **Quick Toggle** | `Prefix` + `Space` | **New!** Jump to the last active window. |
| **Next Window** | `Prefix` + `n` |
| **Previous Window**| `Prefix` + `p` |
| **Rename Window** | `Prefix` + `,` |
| **Kill Window** | `Prefix` + `&` |

#### 3. Panes (The "Splits")

Each window can be divided into multiple panes.

| Action | Keybinding |
| :--- | :--- |
| **Split Vertically** | `Prefix` + `\|` |
| **Split Horizontally**| `Prefix` + `-` |
| **Zoom/Maximize** | `Prefix` + `z` OR `m` | **New!** Both standard `z` and easier `m` toggle full-screen. |
| **Kill Pane** | `Prefix` + `x` |
| **Break to Window** | `Prefix` + `b` |

#### 4. Unified Navigation (The "Sakura" Bridge)

**This is your primary navigation method.** It unifies Neovim and Tmux.

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Focus Left** | `Ctrl` + `h` | Moves focus left, crossing from Neovim into Tmux seamlessly. |
| **Focus Down** | `Ctrl` + `j` | Moves focus down. |
| **Focus Up** | `Ctrl` + `k` | Moves focus up. |
| **Focus Right** | `Ctrl` + `l` | Moves focus right. |

*Secondary Method (Within Tmux Only):*

* **Select Pane:** `Prefix` + `h/j/k/l`
* **Resize Pane:** `Prefix` + `H/J/K/L` (Hold `Prefix` and tap the letter repeatedly).

#### 5. Copy & Paste (Text Manipulation)

On macOS, copy mode uses `pbcopy` to sync with the system clipboard. On Linux, it uses `xclip` (must be installed).

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **1. Enter Copy Mode**| `Prefix` + `[` | Allows scrolling and text selection. |
| **2. Begin Selection**| `v` | While in copy mode, press `v` to start selecting (Vim-style). |
| **3. Yank (Copy)** | `y` | Yanks the selection to **both** Tmux buffer and system clipboard (`pbcopy`/`xclip`). |
| **Paste** | `Prefix` + `]` | Pastes from the Tmux buffer. (Standard `Cmd+V` / `Ctrl+Shift+V` also works). |

#### 6. Plugin Features (Your Superpowers)

| Plugin | Keybinding | Action |
| :--- | :--- | :--- |
| **TPM** | `Prefix` + `I` | **I**nstall any new plugins from your config. |
| | `Prefix` + `U` | **U**pdate all installed plugins. |
| **Resurrect** | `Prefix` + `Ctrl`+`s`| **S**ave the current session layout manually. |
| | `Prefix` + `Ctrl`+`r`| **R**estore the last saved session manually. |

#### 7. Mouse Controls

Your config has `set -g mouse on`.

| Action | How to Use |
| :--- | :--- |
| **Select Pane** | Click inside the pane. |
| **Resize Pane** | Click and drag the border between panes. |
| **Select Text** | Click and drag to highlight text (automatically enters copy mode). |
| **Scroll** | Use your mouse wheel or trackpad to scroll up/down. |

#### 8. System & Configuration

| Action | Keybinding |
| :--- | :--- |
| **Reload Config** | `Prefix` + `r` |
| **List all keybinds** | `Prefix` + `?` |
| **Enter Command Mode**| `Prefix` + `:` |

---

### Zsh
*Your interactive shell.*

#### 1. Core Concepts (How it "Thinks")

* **Prompt:** It shows `user@host`, a shortened path, the current Git branch, and a status symbol (`✓` for clean, `⚡️` for dirty).
* **Plugins:** Oh My Zsh manages plugins that add new commands, aliases, and behaviors.
* **Aliases:** These are custom shortcuts for longer commands (e.g., `gs` for `git status -sb`).
* **Functions:** More powerful than aliases, these are small shell scripts (e.g., `mkcd`).

#### 2. Navigation & File System (The "Modern Unix" Suite)

You have replaced standard commands with faster, more informative versions.

| Action | Command | Description |
| :--- | :--- | :--- |
| **Smart CD** | `cd` or `z` | **Zoxide.** Both commands now use `zoxide` to jump to directories instantly. |
| **List Files** | `ls` | **Eza.** Shows files with icons and Git status. |
| **List Detailed** | `ll` | **Eza.** Shows a detailed list with permissions, size, and date. |
| **Show Tree** | `tree` | **Eza.** Shows a hierarchical tree view of the current directory (2 levels deep). |
| **View File** | `cat <file>` | **Bat.** Displays file content with syntax highlighting and line numbers. |

#### 3. History & Completion (The "Speed" Features)

These features are designed to minimize typing.

| Tool | Action | Keybinding / How to Use |
| :--- | :--- | :--- |
| **zsh-autosuggestions** | Accept "Ghost Text" | Press **`Ctrl+Space`** or **Right Arrow (`→`)**. |
| | | *The grey text is a suggestion from your command history.* |
| **fzf-tab** | Interactive Completion | Press **`Tab`** on any command (e.g., `cd`, `nvim`, `rm`). |
| | | *An interactive, fuzzy-searchable menu of files will appear.* |
| **fzf** | Fuzzy History Search | Press **`Ctrl+r`**. |
| | | *A full-screen menu of your command history appears. Start typing to filter it.* |
| **fzf** | Fuzzy File Path Insert | Press **`Ctrl+t`**. |
| | | *Inserts the selected file path directly into your current command line.* |

#### 4. Aliases (Your Personal Shortcuts)

This is a curated list of the most important aliases you've configured.

**System & Config:**

| Alias | Expands to... |
| :--- | :--- |
| `reload` | `source ~/.zshrc` |
| `zshconfig` | `nvim ~/.zshrc` |
| `update` | Updates macOS, Homebrew, and Oh My Zsh. |
| `bbu` | `brew bundle dump --file=~/dotfiles/Brewfile --force` (Updates repo Brewfile) |
| `icloud` | Opens your iCloud Drive folder. |

**Safety:**

| Alias | Expands to... |
| :--- | :--- |
| `rm` | `rm -i` (Interactive prompt before deleting). |
| `cp` | `cp -i` (Interactive prompt before overwriting). |
| `mv` | `mv -i` (Interactive prompt before overwriting). |

**Git (Standard):**

| Alias | Expands to... |
| :--- | :--- |
| `gs` | `git status -sb` |
| `gaa` | `git add .` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate --all` |
| `gpl` | `git pull --rebase --autostash` (Safer pulling). |

**Git (Advanced):**

| Alias | Expands to... |
| :--- | :--- |
| `lg` | `lazygit` (Opens the Terminal UI for Git). |
| `gpf` | `git push --force-with-lease` (Safer force push). |

**Python / AI:**

| Alias | Expands to... |
| :--- | :--- |
| `venv` | `python3 -m venv .venv` |
| `venvact` | `source .venv/bin/activate` |
| `explain` | `gemini 'Explain this error message...'` (Used with pipes). |

**Tmux:**

| Alias | Expands to... |
| :--- | :--- |
| `ta` | Smart attach/create function. |
| `tls` | `tmux ls` |
| `tk <name>`| `tmux kill-session -t <name>` |

#### 5. Functions (Mini-Scripts)

These perform actions that aliases cannot.

| Function | How to Use |
| :--- | :--- |
| `mkcd <dir>` | Creates a directory and immediately `cd`s into it. |
| `ic` | Jumps directly to your iCloud Drive folder. |
| `nom` | Wrapper to auto-switch themes based on macOS settings. |
| `gemini` | Wrapper to auto-switch themes based on macOS settings. |

#### 6. Tool Initializations (The "Magic")

These lines in your `.zshrc` are what enable the version managers.

| Command | What it does |
| :--- | :--- |
| `nvm` | **Lazy Loaded.** NVM loads only when you run `node`, `npm`, etc., speeding up shell start. |

---

## Notes

- `fzf` keybindings are loaded from `fzf.zsh` when present (tracked in this repo), otherwise `fzf --zsh` is used.
- Homebrew dependencies are managed in a single `Brewfile` (casks included).
- `.bash_profile` includes Juliaup and a lazy-loaded Conda hook.

---

## License

This project is licensed under the MIT License.
