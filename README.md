# Dotfiles

![Shell](https://img.shields.io/badge/shell-Zsh-blue.svg)
![Editor](https://img.shields.io/badge/editor-Neovim-green.svg)
![Terminal](https://img.shields.io/badge/terminal-Ghostty-purple.svg)
![Multiplexer](https://img.shields.io/badge/multiplexer-tmux-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

This repository contains configuration files for a high-performance, terminal-centric development environment on macOS and Linux. The setup integrates Ghostty, Zsh, Tmux, and Neovim into a unified workspace, prioritizing keyboard-driven navigation, fast startup times, and platform-aware behavior.

---

## Structure

The repo is organized around stable root dispatchers plus platform-specific deployment targets and shared implementation modules:

- Root dispatchers: `.zshrc`, `.bash_profile`, `.tmux.conf`, `install.sh`
- Platform deployment targets: `platforms/macos/` and `platforms/ubuntu/` for Zsh, Bash, and Starship
- Shared shell logic: `shell/shared/platform.sh`
- Bash profile logic: `shell/bash/profile.bash`
- OS-specific Bash config: separate macOS and Linux files under `shell/bash/`
- Zsh modules: `shell/zsh/` for path, env, platform behavior, aliases, functions, integrations, and language managers
- OS-specific Zsh config: separate macOS and Linux files under `shell/zsh/path/`, `shell/zsh/plugins/`, and `shell/zsh/platform/`
- OS-specific Tmux config: shared loader in `.tmux.conf`, platform files under `tmux/`
- OS-specific Ghostty config: `ghostty/config.macos` and `ghostty/config.linux`
- OS-specific Neovim hooks: shared loader in `nvim/lua/core/platform/` with separate macOS/Linux files
- Toolchain manifest: `config/toolchain.sh` for package lists, version floors, and Neovim tool inventory
- Verification scripts: `scripts/doctor.sh`, `scripts/verify-nvim.sh`, and `scripts/ci-smoke-install.sh`
- Tests: `tests/` for consistency, syntax, installer, bootstrap E2E, and repo hygiene coverage

The `platforms/` tree is the deployment surface for shell prompt/profile files. The `shell/` tree is the implementation surface.

---

## Installation

Follow these steps to deploy the environment on a fresh macOS or Linux installation.

### Phase 1: Deployment

1. **Clone Repository:**
    ```bash
    git clone https://github.com/your-username/dotfiles.git ~/dotfiles
    ```

2. **Run Installation Script:**
    This script detects your platform, backs up existing configurations, creates symbolic links, and sets up the terminal/editor environment. On macOS it installs Homebrew dependencies automatically. On Ubuntu/Linux it skips Homebrew, installs core packages with `apt`, and installs the latest Neovim release from upstream into `~/.local`.
    ```bash
    cd ~/dotfiles
    ./install.sh
    ```
    *Note: The script is safe to run. It will ask for confirmation and backup your old dotfiles to `~/dotfiles_backup_<timestamp>`.*

    **Dry run (no changes):**
    ```bash
    ./install.sh --dry-run
    ```

    **Optional flags:**
    ```bash
    ./install.sh --skip-deps
    ```

    **Read-only verification:**
    ```bash
    ./scripts/doctor.sh
    ./scripts/verify-nvim.sh
    ```

### What Gets Installed

The script handles the following:
- **macOS:** Homebrew packages, casks, and VS Code extensions (from `Brewfile`)
- **Linux:** Ubuntu-first `apt` install for core packages, plus latest upstream Neovim in `~/.local`; no Homebrew install path by default
- **Symlinks** for Zsh, Bash profile, Tmux, Neovim, Starship, Ghostty, and Claude Code configs
- **Default shell switch** to `zsh` when `zsh` and `chsh` are available
- **TPM** (Tmux Plugin Manager)
- **Oh My Zsh** plus `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `fzf-tab`
- **tree-sitter-cli** on Linux via `npm`
- **Rustup** on Linux for Rust-based Neovim plugins
- **Node and Ruby Neovim hosts**
- **pynvim** in the Mason debugpy venv (for Neovim's Python provider)
- **Interactive Neovim bootstrap** for plugins, Mason tooling, treesitter parsers, and DevDocs installs when `install.sh` runs in a real terminal
- **Platform-aware targets** for Ghostty (`~/Library/Application Support/...` on macOS, `~/.config/ghostty/...` on Linux)

### Phase 2: Configuration

1. **Initialize Tmux Plugins:**
    * Start a session: `tmux` or `ta`
    * Press **Ctrl+a** then **I** (Shift+i) to install plugins.

2. **Verify Neovim and shell health:**
    ```bash
    ./scripts/doctor.sh
    nvim "+checkhealth" +qa
    ```

3. **Install Language Runtimes (Optional):**
    `nvm` is lazy-loaded for Node.js. `pyenv` and `rbenv` can be installed separately if you use them; they are not auto-initialized here.
    ```bash
    # Node.js
    nvm install 20
    nvm alias default 20
    ```

---

## Features

### Theme Switching

On macOS, the environment responds to system appearance changes automatically. On Linux, the same themes are available, but automatic switching depends on the individual tool and your desktop environment.

| Component | Dark Theme | Light Theme |
| :--- | :--- | :--- |
| **Neovim** | Kanagawa Wave | Kanagawa Lotus |
| **Ghostty** | Ayu Mirage | Violet Light |
| **Bat** | OneHalfDark | OneHalfLight |
| **Nom** | glamour: dark | glamour: light |
| **Gemini CLI** | Atom One | Google Code |

Neovim switches automatically via [dark-notify](https://github.com/cormacrelf/dark-notify) on macOS. Ghostty uses its built-in `theme = dark:...,light:...` syntax. Shell tools (`bat`, `nom`, `gemini`) can switch at invocation time.

### Format-on-Save

All files are automatically formatted on save via [conform.nvim](https://github.com/stevearc/conform.nvim) with a 500ms timeout and LSP fallback. Configured formatters:

| Language | Formatter |
| :--- | :--- |
| Lua | stylua |
| Python | isort + black |
| JS/TS/CSS/HTML/JSON/Markdown | prettier |
| PHP | php-cs-fixer |
| C/C++ | clang-format |
| Java | google-java-format |
| Ruby | rubocop |
| Go | goimports + gofumpt |
| SQL | sql-formatter |
| Django Templates | djlint |
| Shell | shfmt |

### Linting

Linters run on `BufEnter`, `BufWritePost`, and `InsertLeave` via [nvim-lint](https://github.com/mfussenegger/nvim-lint):

| Language | Linter |
| :--- | :--- |
| Python | flake8 |
| SQL | sqlfluff |
| Shell/Bash | shellcheck |
| Django Templates | djlint |
| C/C++ | cpplint |

Ruby linting is handled by the Solargraph LSP.

### LSP Coverage

Mason installs and Neovim explicitly enables these language servers:

`pyright` `eslint` `html` `cssls` `tailwindcss` `jsonls` `yamlls` `lua_ls` `bashls` `clangd` `ts_ls` `sqlls` `djlsp` `marksman` `texlab`

Notes:
- `djlsp` is restricted to the `htmldjango` filetype and uses `manage.py` root detection.
- JavaScript and TypeScript use both `ts_ls` and `eslint`.
- Formatting stays with `conform.nvim`; LSP is not the primary formatter.

File watching (`workspace/didChangeWatchedFiles`) is enabled with dynamic registration for all clients.

### Treesitter

Syntax highlighting, indentation, and code folding via tree-sitter parsers for the core development stack in this repo, including Python, JavaScript, TypeScript, TSX, HTML, CSS, JSON, YAML, Bash, PHP, Java, C, C++, Rust, Ruby, Go, SQL, Django templates, Markdown, and LaTeX. Includes [treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) for sticky function/class headers at the top of the buffer.

### Session Management

Sessions are managed by [auto-session](https://github.com/rmagatti/auto-session):
- **Auto-save:** On exit (when a session exists)
- **Auto-restore:** Disabled (opens to a blank buffer)
- **Auto-create:** Disabled (use `:SessionSave` to explicitly create a session)
- **Suppressed directories:** `~/`, `~/Downloads`, `/`

Use `:SessionRestore` to manually restore, `:SessionSearch` to browse saved sessions.

### Bat-Highlighted Help Output

Several commands have wrappers that pipe no-argument or `--help` output through `bat` for syntax-highlighted readability: `ssh`, `tldr`, `git`, `rg`, `curl`, `jq`, `docker`, `kubectl`.

### GRC Colorizer

[GRC](https://github.com/garabik/grc) adds color to common commands like `ping`, `traceroute`, `dig`, `mount`, `ps`, etc.

### Testing and CI

The repo includes layered verification:

- `tests/consistency.bats`: structural checks across entrypoints and references
- `tests/syntax.bats`: shell, tmux, and Lua syntax validation
- `tests/install*.bats`: installer dry-run, idempotence, backup behavior, and path coverage
- `tests/bootstrap_e2e.bats`: install-plus-bootstrap checks for Zsh, Tmux, and Neovim
- `tests/ci_smoke_install.bats`: CI smoke-script behavior and release-gate coverage
- `tests/repo_hygiene.bats`: blocks local runtime artifacts from re-entering the repo

Run everything locally with:

```bash
./test.sh
```

GitHub Actions runs the suite on both macOS and Ubuntu. Push/PR CI also runs cross-platform smoke installs, and a separate nightly/manual workflow runs full bootstrap smoke on both OSes.

---

## Cheat Sheet & Keybindings

Below is a comprehensive guide to the tools and keybindings available in this environment.

### Ghostty
*Your GPU-accelerated terminal emulator.*

| Setting | Value |
| :--- | :--- |
| **Font** | FiraCode Nerd Font, size 16 |
| **Opacity** | 90% with background blur |
| **Quick Terminal** | macOS: `Cmd+\``. Linux: use standard window launch or compositor binding |
| **Color Space** | macOS only: Display P3 |
| **Splits/Tabs** | Inherit working directory |
| **Copy** | Copy-on-select to clipboard |
| **Shell Integration** | SSH terminfo + env forwarding |

#### Split Navigation
| Key | Action |
| :--- | :--- |
| macOS: `Cmd+Alt+H` | Focus split left |
| macOS: `Cmd+Alt+J` | Focus split down |
| macOS: `Cmd+Alt+K` | Focus split up |
| macOS: `Cmd+Alt+L` | Focus split right |
| Linux: `Ctrl+Alt+H/J/K/L` | Focus splits |

### Neovim
*Your modal text editor.*

#### General
| Key | Action |
| :--- | :--- |
| `<Space>` | **Leader Key** |
| `<Leader>w` | Save File |
| `<Leader>q` | Quit Window |
| `<Leader>Q` | Force Quit All |
| `<Leader>R` | Restart Neovim and restore the current session |
| `<Leader><Space>` | Clear Search Highlight |
| `<C-\>` | Toggle Floating Terminal (ToggleTerm) |
| `<Leader>u` | Toggle Undo Tree |
| `<Leader>o` | Toggle Symbol Outline (Aerial) |

#### Navigation & Windows
| Key | Action |
| :--- | :--- |
| `<C-h>` | Navigate Left (Tmux/Split) |
| `<C-j>` | Navigate Down (Tmux/Split/Trouble Panel) |
| `<C-k>` | Navigate Up (Tmux/Split/Trouble Panel) |
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
| `gD` | Goto Declaration |
| `gi` | Goto Implementation |
| `gr` | Goto References |
| `K` | Hover Documentation (LSP or per-language fallback) |
| `<Leader>K` | Open DevDocs for the current filetype |
| `<Leader>ca` | Code Action |
| `<Leader>ci` | Incoming Calls (Call Hierarchy) |
| `<Leader>co` | Outgoing Calls (Call Hierarchy) |
| `<Leader>rn` | Rename Symbol (live preview) |
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
| `[d` / `]d` | Previous / Next Diagnostic |
| `[q` / `]q` | Previous / Next Quickfix Item |
| `[Q` / `]Q` | First / Last Quickfix Item |

#### Testing (Neotest)
| Key | Action |
| :--- | :--- |
| `<Leader>nt` | Run Nearest Test |
| `<Leader>nf` | Run All Tests in File |
| `<Leader>ns` | Toggle Test Summary |
| `<Leader>no` | Show Test Output |

*Adapters: Python (pytest), JavaScript (jest), Go, Rust*

#### Git
| Key | Action |
| :--- | :--- |
| `<Leader>gg` | Open LazyGit |
| `<Leader>gd` | Git Diff View (Diffview) |
| `<Leader>gh` | Git File History (Diffview) |

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

*Adapters: Python (debugpy), Go (delve), C/C++/Rust (codelldb)*

#### Running Tasks (Overseer)
| Key | Action |
| :--- | :--- |
| `<Leader>tr` | **Run Task.** Lists auto-detected tasks (make, npm, cargo, go, etc.). |
| `<Leader>to` | Toggle the Task Output window. |
| `<Leader>tc` | Run a custom shell command. |

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

#### Which-Key Groups
Press `<Leader>` and wait to see all available key groups:
| Prefix | Group |
| :--- | :--- |
| `<Leader>f` | Find |
| `<Leader>c` | Code |
| `<Leader>d` | Debug |
| `<Leader>g` | Git |
| `<Leader>n` | Neotest |
| `<Leader>t` | Tasks |

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
| **Quick Toggle** | `Prefix` + `Space` | Jump to the last active window. |
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
| **Zoom/Maximize** | `Prefix` + `z` OR `m` | Both standard `z` and easier `m` toggle full-screen. |
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

* **Prompt:** Powered by Starship. Shows `user@host`, shortened path, Git branch/status, and command duration with millisecond precision.
  Also shows the active Python virtualenv, `direnv` state, background jobs, and failed exit status when present.
* **Plugins:** Oh My Zsh manages plugins that add new commands, aliases, and behaviors.
* **Aliases:** Custom shortcuts for longer commands (e.g., `gs` for `git status -sb`).
* **Functions:** More powerful than aliases, small shell scripts (e.g., `mkcd`).

#### 2. Navigation & File System (The "Modern Unix" Suite)

You have replaced standard commands with faster, more informative versions.

| Action | Command | Description |
| :--- | :--- | :--- |
| **Smart CD** | `cd` or `z` | **Zoxide.** Both commands now use `zoxide` to jump to directories instantly. |
| **List Files** | `ls` | **Eza.** Shows files with icons and Git status. |
| **List Detailed** | `ll` | **Eza.** Shows a detailed list with permissions, size, and date. |
| **List All** | `la` | **Eza.** Shows all files including hidden, with icons and git status. |
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
| **fzf** | Fuzzy Directory Change | Press **`Alt+c`**. |
| | | *Fuzzy find a directory and `cd` into it.* |

#### 4. Aliases (Your Personal Shortcuts)

This is a curated list of the most important aliases you've configured.

**System & Config:**

| Alias | Expands to... |
| :--- | :--- |
| `reload` | `source ~/.zshrc` |
| `zshconfig` | `nvim ~/.zshrc` |
| `cls` | `clear` |
| `update` | macOS: updates system software, Homebrew, Oh My Zsh. Linux: runs Ubuntu/Debian `apt` update/upgrade. |
| `bbu` | Dumps current Homebrew packages to `Brewfile` when `brew` is installed. |
| `icloud` | Opens iCloud Drive folder on macOS. |

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
| `tka` | Kill all unattached tmux sessions. |

#### 5. Functions (Mini-Scripts)

These perform actions that aliases cannot.

| Function | How to Use |
| :--- | :--- |
| `mkcd <dir>` | Creates a directory and immediately `cd`s into it. |
| `ic` | Jumps directly to your iCloud Drive folder on macOS. |
| `nom` | Wrapper to switch themes based on detected interface style. |
| `gemini` | Wrapper to switch themes based on detected interface style. |

#### 6. Tool Initializations (The "Magic")

These lines in your `.zshrc` are what enable the version managers.

| Command | What it does |
| :--- | :--- |
| `nvm` | **Lazy Loaded.** NVM loads only when you run `node`, `npm`, etc., speeding up shell start. |
| `direnv` | Loads per-project `.envrc` files automatically, useful for `.venv` activation and project env vars. |

---

## Notes

- `fzf` keybindings are loaded from `.fzf.zsh` when present (tracked in this repo), otherwise `fzf --zsh` is used.
- macOS dependencies are tracked in a single `Brewfile` (packages, casks, VS Code extensions, cargo packages).
- Linux instructions are optimized for Ubuntu/Debian. Other distributions should install equivalent packages manually.
- `config/toolchain.sh` is the source of truth for package lists, minimum tool versions, and Neovim bootstrap inventory.
- `.bash_profile` includes Juliaup and a lazy-loaded Conda hook.
- Git is configured with `pull.rebase`, `push.autoSetupRemote`, `rerere`, `fetch.prune`, and `zdiff3` merge conflict style.
- Starship prompt shows command duration only for commands slower than 50ms.
- Starship also shows active `.venv`, `direnv` state, background jobs, and non-zero exit status.
- LSP progress is shown inline via Fidget (no notification popups).
- `:LspStatus` prints the current buffer path, filetype, repo root, and attached LSP clients.
- DevDocs works best through explicit installs or `ensure_installed`; the interactive `:DevdocsInstall` picker is currently unreliable upstream.
- Claude Code is configured via `claude/CLAUDE.md`, symlinked to `~/.claude/CLAUDE.md` by the install script.
- Indent guides are rendered by [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim).

---

## Testing

Run the test suite to verify the configuration:
```bash
./test.sh
```

For machine health and editor contract checks:
```bash
./scripts/doctor.sh
./scripts/verify-nvim.sh
```

The suite currently includes 80 tests covering syntax validation, installation logic, idempotence, symlink correctness, platform-specific shell behavior, CI smoke flows, bootstrap E2E, and cross-file consistency.

---

## License

This project is licensed under the MIT License.
