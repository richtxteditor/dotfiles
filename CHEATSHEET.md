# Dotfiles Cheat Sheet

## Repo Layout

| Path | Role |
| :--- | :--- |
| **`.zshrc`** | Thin Zsh entrypoint that loads the modular shell config. |
| **`.bash_profile`** | Thin Bash entrypoint for login-shell compatibility. |
| **`shell/shared/platform.sh`** | Shared macOS/Linux detection and path helpers. |
| **`shell/zsh/`** | Zsh modules split by concern: path, env, platform, aliases, functions, integrations, runtimes. |
| **`install.sh`** | Platform-aware install script with backup and symlink orchestration. |
| **`tests/`** | Syntax, install, bootstrap E2E, and hygiene coverage. |

## Shell & Navigation (Zsh)

| Command | Tool | Description |
| :--- | :--- | :--- |
| **`z <dir>`** | **zoxide** | Smart `cd`. Jumps to directories based on frequency (e.g., `z dot` → `~/Sites/dotfiles`). |
| **`ls`** / **`ll`** | **eza** | Lists files with icons, git status, and headers. |
| **`tree`** | **eza** | Shows a directory tree (2 levels deep). |
| **`cat <file>`** | **bat** | Displays file contents with syntax highlighting and line numbers. |
| **`Ctrl + r`** | **fzf** | Fuzzy search your command history. |
| **`Ctrl + t`** | **fzf** | Fuzzy find a file and paste its path into the command line. |
| **`Ctrl + Space`**| **autosuggest**| Accept the grey "ghost text" suggestion. |

## System & Config Management

| Command | Description |
| :--- | :--- |
| **`update`** | Runs **all** updates: macOS, Homebrew, and Oh My Zsh. |
| **`bbu`** | **B**rew **B**undle **U**pdate. Dumps current brew packages to the repo's `Brewfile`. |
| **`zshconfig`** | Opens `.zshrc` in Neovim; module implementations live under `shell/zsh/`. |
| **`reload`** | Reloads `.zshrc` without restarting the terminal. |
| **`mkcd <dir>`**| Creates a directory and immediately `cd`s into it. |

## Testing & CI

| Command | Description |
| :--- | :--- |
| **`./test.sh`** | Runs the full local BATS suite. |
| **`bats tests/bootstrap_e2e.bats`** | Runs install-plus-bootstrap end-to-end checks. |
| **`bats tests/repo_hygiene.bats`** | Verifies local runtime artifacts are not in the repo. |
| **GitHub Actions** | Runs `./test.sh` on both macOS and Ubuntu. |

## Git Workflow

| Command | Description |
| :--- | :--- |
| **`lg`** | **Lazygit**. Opens a powerful terminal UI for Git. |
| **`gs`** | `git status -sb` (Short status). |
| **`gaa`** | `git add .` (Add all). |
| **`gc "msg"`** | `git commit -m "msg"`. |
| **`gp`** | `git push`. |
| **`gpf`** | `git push --force-with-lease` (Safer force push). |
| **`gpl`** | `git pull --rebase --autostash`. |

## Tmux (Multiplexer)
**Prefix:** `Ctrl + a` (Replaces standard `Ctrl + b`)

| Key | Action |
| :--- | :--- |
| **`ta`** | **Smart Alias:** Attaches to the last session or creates a new one. |
| **`Ctrl + h/j/k/l`** | **Seamless Navigation:** Move between Tmux panes **and** Neovim splits. |
| **`Prefix + |`** | Split vertically. |
| **`Prefix + -`** | Split horizontally. |
| **`Prefix + c`** | New window. |
| **`Prefix + z`** / **`m`** | Toggle fullscreen (zoom) for current pane. |
| **`Prefix + Space`** | Jump to last active window. |
| **`Prefix + I`** | **Install Plugins** (Press this if plugins look missing). |
| **`Prefix + [`** | Enter copy mode (Use `v` to select, `y` to copy). |
| **`Prefix + d`** | Detach from session (leave it running in background). |

## Neovim (Editor)
**Leader Key:** `Space`

### General & Files
| Key | Action |
| :--- | :--- |
| **`<Space> e`** | Toggle File Explorer (NvimTree). |
| **`ff`** | **FFFind Files** (FFF - High Performance). |
| **`fg`** | **LiFFFe Grep** (FFF - High Performance). |
| **`fz`** | **Fuzzy Grep** (FFF). |
| **`<Space> ff`** | Find Files (Telescope). |
| **`<Space> fg`** | Live Grep (Telescope). |
| **`<Space> fo`** | Find Recent/Old Files. |
| **`<Space> fb`** | Find Buffers. |
| **`<Space> fh`** | Find Help Tags. |
| **`<Space> fd`** | Find Diagnostics. |
| **`<Space> ft`** | Find TODOs. |
| **`<Space> gg`** | Open Lazygit. |
| **`<Space> mp`** | Toggle Markdown Preview. |
| **`<C-\>`** | Toggle floating terminal (ToggleTerm). |
| **`<Space> u`** | Toggle Undo Tree. |
| **`<Space> o`** | Toggle Symbol Outline (Aerial). |

### Code & LSP
| Key | Action |
| :--- | :--- |
| **`gd`** | Go to Definition. |
| **`gD`** | Go to Declaration. |
| **`gi`** | Go to Implementation. |
| **`gr`** | Find References. |
| **`K`** | Hover Documentation (LSP or per-language fallback). |
| **`<Space> K`** | Open DevDocs for the current filetype. |
| **`<Space> cf`** | Format Code. |
| **`<Space> rn`** | Rename Symbol (live preview). |
| **`<Space> ca`** | Code Action. |
| **`<Space> ci`** | Incoming Calls (call hierarchy). |
| **`<Space> co`** | Outgoing Calls (call hierarchy). |
| **`<Space> dd`** | Show Error/Warning (Float). |
| **`[d`** / **`]d`** | Previous / Next Diagnostic. |
| **`[q`** / **`]q`** | Previous / Next Quickfix Item. |
| **`<Space> xx`** | Toggle Diagnostics (Trouble). |

### Testing (Neotest)
| Key | Action |
| :--- | :--- |
| **`<Space> nt`** | Run Nearest Test. |
| **`<Space> nf`** | Run All Tests in File. |
| **`<Space> ns`** | Toggle Test Summary. |
| **`<Space> no`** | Show Test Output. |

### Debugging (DAP)
| Key | Action |
| :--- | :--- |
| **`<F5>`** | Start / Continue. |
| **`<F6>`** | Stop / Terminate. |
| **`<F9>`** | Toggle Breakpoint. |
| **`<F10>`** | Step Over. |
| **`<F11>`** | Step Into. |
| **`<F8>`** | Step Out. |
| **`<Space> du`** | Toggle Debug UI. |

### Tasks & Running (Overseer)
| Key | Action |
| :--- | :--- |
| **`<Space> tr`** | **Run Task** (Auto-detected: make, npm, cargo, go, etc.). |
| **`<Space> to`** | Toggle Task Output. |
| **`<Space> tc`** | Run Custom Command. |

### Git (in Neovim)
| Key | Action |
| :--- | :--- |
| **`<Space> gg`** | Open LazyGit. |
| **`<Space> gd`** | Git Diff View (Diffview). |
| **`<Space> gh`** | Git File History (Diffview). |

### Navigation (Flash)
| Key | Action |
| :--- | :--- |
| **`s`** | **Flash Jump**. Jump to any character on screen. |
| **`S`** | **Flash Treesitter**. Select logical blocks of code. |

## Runtimes & Languages

| Tool | Usage |
| :--- | :--- |
| **Node.js** | Managed by `nvm`. Run `nvm install 20`. |
| **Python** | Managed by `pyenv`. Run `pyenv install 3.12`. |
| **Ruby** | Managed by `rbenv`. Run `rbenv install 3.3.0`. |
| **Go** | Installed via Homebrew. LSP: `gopls`. Formatters: `goimports`, `gofumpt`. |
| **Rust** | Installed via Homebrew. LSP: `rust-analyzer`. DAP: `codelldb`. |
| **Java** | `openjdk` installed. Neovim uses `jdtls` & `google-java-format`. |
| **C/C++** | `clang` / `llvm` installed. Neovim uses `clangd` & `clang-format`. DAP: `codelldb`. |
| **TypeScript** | Uses `ts_ls`, `prettier`, `eslint`. Ensure `tsconfig.json` exists. |
| **PHP** | Uses `intelephense` & `php-cs-fixer`. |

## DevDocs Setup (First Time)

After installing plugins, run these commands in Neovim to download offline docs:
```
:DevdocsFetch
:DevdocsInstall python~3.12 javascript typescript html css tailwindcss django~5.2 c cpp postgresql~18
```

Use `:LspStatus` to inspect the current buffer path, filetype, project root, and attached LSP clients.

`direnv` is integrated into Zsh. Add an `.envrc` in a project root, run `direnv allow`, and Neovim will inherit the correct project environment when launched from that shell.
