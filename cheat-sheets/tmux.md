# Tmux Cheat Sheet

**Prefix Key:** `Ctrl + a`

## 1. Session Management (The "Workspaces")

Your `tmux-resurrect` and `continuum` plugins make sessions persistent across reboots.

| Action | Keybinding / Command | Description |
| :--- | :--- | :--- |
| **Start / Attach** | `ta` (alias) | **Your entry point.** Smartly attaches to the last session or creates a new one. |
| **Detach Session** | `Prefix` + `d` | Detach from the current session (it keeps running). |
| **List Sessions** | `Prefix` + `s` | Show an interactive list of all sessions to switch between. |
| **Rename Session** | `Prefix` + `$` | Rename the current session. |
| **Kill Server** | `tmux kill-server` | **The "Nuke" Option.** Kills all sessions and the Tmux process itself. Use when things get stuck. |

## 2. Windows (The "Tabs")

Each window is a full-screen workspace within a session.

| Action | Keybinding |
| :--- | :--- |
| **New Window** | `Prefix` + `c` |
| **Next Window** | `Prefix` + `n` |
| **Previous Window**| `Prefix` + `p` |
| **Rename Window** | `Prefix` + `,` |
| **Kill Window** | `Prefix` + `X` |

## 3. Panes (The "Splits")

Each window can be divided into multiple panes.

| Action | Keybinding |
| :--- | :--- |
| **Split Vertically** | `Prefix` + `\|` |
| **Split Horizontally**| `Prefix` + `-` |
| **Zoom Pane** | `Prefix` + `z` |
| **Kill Pane** | `Prefix` + `x` |
| **Break to Window** | `Prefix` + `b` |

## 4. Unified Navigation (The "Sakura" Bridge)

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

## 5. Copy & Paste (Text Manipulation)

Your `tmux-yank` plugin syncs this with the system clipboard.

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **1. Enter Copy Mode**| `Prefix` + `[` | Allows scrolling and text selection. |
| **2. Begin Selection**| `v` | While in copy mode, press `v` to start selecting (Vim-style). |
| **3. Yank (Copy)** | `y` | Yanks the selection to **both** Tmux buffer and system clipboard. |
| **Paste** | `Prefix` + `]` | Pastes from the Tmux buffer. (Standard `Cmd+V` also works). |

## 6. Plugin Features (Your Superpowers)

| Plugin | Keybinding | Action |
| :--- | :--- | :--- |
| **TPM** | `Prefix` + `I` | **I**nstall any new plugins from your config. |
| | `Prefix` + `U` | **U**pdate all installed plugins. |
| **Resurrect** | `Prefix` + `Ctrl`+`s`| **S**ave the current session layout manually. |
| | `Prefix` + `Ctrl`+`r`| **R**estore the last saved session manually. |
| **Continuum** | (Automatic) | Saves your session every 15 minutes and on Tmux start. |
| **Open** | `Prefix` + `o` | **O**pen a file path or URL under your cursor in its default app. |
| **Sessionist** | `Prefix` + `T` | Show an easy session management menu. |

## 7. Mouse Controls

Your config has `set -g mouse on`.

| Action | How to Use |
| :--- | :--- |
| **Select Pane** | Click inside the pane. |
| **Resize Pane** | Click and drag the border between panes. |
| **Select Text** | Click and drag to highlight text (automatically enters copy mode). |
| **Scroll** | Use your mouse wheel or trackpad to scroll up/down. |

## 8. System & Configuration

| Action | Keybinding |
| :--- | :--- |
| **Reload Config** | `Prefix` + `r` |
| **List all keybinds** | `Prefix` + `?` |
| **Enter Command Mode**| `Prefix` + `:` |
