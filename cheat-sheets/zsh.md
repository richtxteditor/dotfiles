# Zsh Cheat Sheet

## 1. Core Concepts (How it "Thinks")

* **Prompt:** It shows `user@host`, a shortened path, the current Git branch, and a status symbol (`✓` for clean, `⚡️` for dirty).
* **Plugins:** Oh My Zsh manages plugins that add new commands, aliases, and behaviors.
* **Aliases:** These are custom shortcuts for longer commands (e.g., `gs` for `git status -sb`).
* **Functions:** More powerful than aliases, these are small shell scripts (e.g., `mkcd`).

## 2. Navigation & File System (The "Modern Unix" Suite)

You have replaced standard commands with faster, more informative versions.

| Action | Command | Description |
| :--- | :--- | :--- |
| **Smart CD** | `z <name>` | **Zoxide.** Jumps to the most frequent directory matching `<name>`. |
| **List Files** | `ls` | **Eza.** Shows files with icons and Git status. |
| **List Detailed** | `ll` | **Eza.** Shows a detailed list with permissions, size, and date. |
| **Show Tree** | `tree` | **Eza.** Shows a hierarchical tree view of the current directory (2 levels deep). |
| **View File** | `cat <file>` | **Bat.** Displays file content with syntax highlighting and line numbers. |

## 3. History & Completion (The "Speed" Features)

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

---

## 4. Aliases (Your Personal Shortcuts)

This is a curated list of the most important aliases you've configured.

**System & Config:**

| Alias | Expands to... |
| :--- | :--- |
| `reload` | `source ~/.zshrc` |
| `zshconfig` | `nvim ~/.zshrc` |
| `update` | Updates macOS, Homebrew, and Oh My Zsh. |
| `bbu` | `brew bundle dump --file=~/dotfiles/Brewfile --force` |

**Git (Standard):**

| Alias | Expands to... |
| :--- | :--- |
| `gs` | `git status -sb` |
| `gaa` | `git add .` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate --all` |

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

## 5. Functions (Mini-Scripts)

These perform actions that aliases cannot.

| Function | How to Use |
| :--- | :--- |
| `mkcd <dir>` | Creates a directory and immediately `cd`s into it. |
| `ic` | Jumps directly to your iCloud Drive folder. |
| `nom` | Wrapper to auto-switch themes based on macOS settings. |
| `gemini` | Wrapper to auto-switch themes based on macOS settings. |

## 6. Tool Initializations (The "Magic")

These lines in your `.zshrc` are what enable the version managers.

| Command | What it does |
| :--- | :--- |
| `nvm use <ver>` | Switch to a specific Node.js version. |
| `pyenv global <ver>` | Set the default Python version for your user. |
| `rbenv global <ver>` | Set the default Ruby version for your user. |
