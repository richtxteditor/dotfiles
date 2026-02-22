# Dotfiles Cheat Sheet

A quick reference guide for the tools, aliases, and keybindings in your high-performance terminal environment.

## 🚀 Shell & Navigation (Zsh)

| Command | Tool | Description |
| :--- | :--- | :--- |
| **`z <dir>`** | **zoxide** | Smart `cd`. Jumps to directories based on frequency (e.g., `z dot` → `~/Sites/dotfiles`). |
| **`ls`** / **`ll`** | **eza** | Lists files with icons, git status, and headers. |
| **`tree`** | **eza** | Shows a directory tree (2 levels deep). |
| **`cat <file>`** | **bat** | Displays file contents with syntax highlighting and line numbers. |
| **`Ctrl + r`** | **fzf** | Fuzzy search your command history. |
| **`Ctrl + t`** | **fzf** | Fuzzy find a file and paste its path into the command line. |
| **`Ctrl + Space`**| **autosuggest**| Accept the grey "ghost text" suggestion. |

## 🛠 System & Config Management

| Command | Description |
| :--- | :--- |
| **`update`** | Runs **all** updates: macOS, Homebrew, and Oh My Zsh. |
| **`bbu`** | **B**rew **B**undle **U**pdate. Dumps current brew packages to the repo's `Brewfile`. |
| **`zshconfig`** | Opens `.zshrc` in Neovim. |
| **`reload`** | Reloads `.zshrc` without restarting the terminal. |
| **`mkcd <dir>`**| Creates a directory and immediately `cd`s into it. |
| **`nom`** | Starts `nom` with auto-switching theme (Light/Dark). |

## 🌳 Git Workflow

| Command | Description |
| :--- | :--- |
| **`lg`** | **Lazygit**. Opens a powerful terminal UI for Git. (Highly recommended). |
| **`gs`** | `git status -sb` (Short status). |
| **`gaa`** | `git add .` (Add all). |
| **`gc "msg"`** | `git commit -m "msg"`. |
| **`gp`** | `git push`. |
| **`gpf`** | `git push --force-with-lease` (Safer force push). |
| **`gpl`** | `git pull --rebase --autostash`. |

## 🖥 Tmux (Multiplexer)
**Prefix:** `Ctrl + a` (Replaces standard `Ctrl + b`)

| Key | Action |
| :--- | :--- |
| **`ta`** | **Smart Alias:** Attaches to the last session or creates a new one. |
| **`Ctrl + h/j/k/l`** | **Seamless Navigation:** Move between Tmux panes **and** Neovim splits. |
| **`Prefix + |`** | Split vertically. |
| **`Prefix + -`** | Split horizontally. |
| **`Prefix + c`** | New window. |
| **`Prefix + z`** / **`m`** | Toggle fullscreen (zoom) for current pane. |
| **`Prefix + I`** | **Install Plugins** (Press this if plugins look missing). |
| **`Prefix + [`** | Enter copy mode (Use `v` to select, `y` to copy). |
| **`Prefix + d`** | Detach from session (leave it running in background). |

## 📝 Neovim (Editor)
**Leader Key:** `Space`

| Key | Action |
| :--- | :--- |
| **`<Space> e`** | Toggle File Explorer (NvimTree). |
| **`<Space> ff`** | **Find Files** (Telescope). Fuzzy find files by name. |
| **`<Space> fg`** | **Live Grep**. Search for text across the entire project. |
| **`<Space> gg`** | Open Lazygit inside Neovim. |
| **`<Space> cf`** | Format Code. |
| **`gd`** | Go to Definition. |
| **`K`** | Hover Documentation. |
| **`<Space> xx`** | Toggle Diagnostics Panel (Trouble). |

## 📦 Runtimes & Languages

| Tool | Usage |
| :--- | :--- |
| **Node.js** | Managed by `nvm` (Lazy-loaded). Run `nvm install 20` to use. |
| **Python** | Managed by `pyenv`. Run `pyenv install 3.12` to use. |
| **Ruby** | Managed by `rbenv`. Run `rbenv install 3.3.0` to use. |
