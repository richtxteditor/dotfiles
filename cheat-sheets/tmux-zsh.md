# Your Personalized `tmux` Command Sheet

**Your Prefix Key: `Ctrl + a`** (referred to as `<Prefix>`)

## Session Management (via Zsh)

*These are the aliases/functions you type in your Zsh terminal to manage tmux.*

| Command | Action |
| :--- | :--- |
| **`ta`** | **A**ttach to tmux. **Your main command to enter tmux.** Starts server and restores sessions if needed. |
| **`tls`** | **L**ist **s**essions currently running. |
| **`tns <name>`** | Create a **n**ew **s**ession with a specific `<name>`. |
| **`tka`** | **K**ill **a**ll other sessions except the one you are currently attached to. |
| **`tk <id>`** | **K**ill a specific session by its ID number. |

## Windows & Panes

*These commands are used inside tmux, after pressing `<Prefix>`.*

| Keystroke | Action |
| :--- | :--- |
| **`<Prefix> + c`** | **C**reate a new window in the current directory. |
| **`<Prefix> + n`** | Go to the **n**ext window. |
| **`<Prefix> + p`** | Go to the **p**revious window. |
| **`<Prefix> + X`** | Kill the current **W**indow (with confirmation). |
| **`<Prefix> + ,`** | Rename the current window. |
| **`<Prefix> + \|`** | Split the current pane vertically (`\|`). |
| **`<Prefix> + -`** | Split the current pane horizontally (`-`). |
| **`<Prefix> + h/j/k/l`** | Move to the pane to the Left/Down/Up/Right. |
| **`<Prefix> + H/J/K/L`** | **R**esize the current pane Left/Down/Up/Right. (Repeatable) |
| **`<Prefix> + z`** | **Z**oom/un-zoom the current pane to fill the window. |
| **`<Prefix> + x`** | Kill the current pane (with confirmation). |
| **`<Prefix> + b`** | **B**reak the current pane out into its own new window. |

## Copy Mode (Vi Style)

*For copying text from the terminal scrollback.*

| Keystroke | Action |
| :--- | :--- |
| **`<Prefix> + Enter`** | Enter Copy Mode. You can now use `hjkl` to navigate. |
| **`v`** | (In Copy Mode) Begin selection. |
| **`y`** | (In Copy Mode) **Y**ank (copy) the selected text to the system clipboard. |

## Plugin Commands

| Keystroke | Action & Plugin |
| :--- | :--- |
| **`<Prefix> + I`** | **I**nstall TPM plugins (run this after adding a new plugin to `.tmux.conf`). |
| **`<Prefix> + T`** | Show the **T**mux Sessionist menu for easy session switching. |
| **`<Prefix> + o`** | **O**pen a highlighted file path or URL from the buffer. |

---

### Your Personalized `zsh` Command Sheet

**Your personal aliases, functions, and key Zsh features.**

#### General & System

| Command | Action |
| :--- | :--- |
| **`reload`** | Reloads your `.zshrc` configuration instantly. |
| **`zshconfig`** | Opens your `.zshrc` file in your default editor (`nvim`). |
| **`update`** | A full system update: macOS, Homebrew, and Oh My Zsh. |
| **`cls`** | A simple alias to `clear` the screen. |

#### File & Directory Navigation

| Command | Action |
| :--- | :--- |
| **`l`** | **L**ist files in columns. |
| **`ll`** | **L**ist files in **l**ong format with details. |
| **`la`** | **L**ist **a**ll files, including hidden ones. |
| **`lsd`** | **L**ist only **d**irectories in the current path. |
| **`z <partial_name>`** | Jump to a frequently visited directory. E.g., `z fusion` will jump to `~/Sites/fusion_manaba_backend`. |
| **`mkcd <dir>`** | **M**a**k**e a new **d**irectory and `cd` into it in one step. |
| **`ic`** | Jump directly to your **iC**loud Drive directory. |
| **`cd -`** | Go back to the previous directory you were in. |

#### Git Workflow

*These are your most common shortcuts. The `git` plugin provides many more.*

| Alias | Action |
| :--- | :--- |
| **`gs`** | `git status -sb` (a short, branch-aware status). |
| **`gl`** | A pretty, one-line `git log`. |
| **`gaa`** | `git add .` (add all changes). |
| **`gc "message"`** | `git commit -m "message"`. |
| **`gca "message"`** | `git commit -am "message"` (add and commit in one step). |
| **`gpl`** | `git pull` using a safe rebase strategy. **Your daily pull command.** |
| **`gp`** | `git push`. |
| **`gpf`** | `git push --force-with-lease` (a safer way to force push). |

#### Python Workflow

| Alias | Action |
| :--- | :--- |
| **`venv`** | Creates a new Python virtual environment named `.venv`. |
| **`venvact`** | Activates the local `.venv` virtual environment. |

#### Zsh Power Features (Built-in or from Plugins)

| Keystroke | Action |
| :--- | :--- |
| **`Tab`** | Autocomplete commands, arguments, and paths. Use arrow keys to navigate the menu. |
| **`Ctrl + r`** | Reverse search through your command history. |
| **`Right Arrow` →** | Accept the full command suggestion from `zsh-autosuggestions`. |

**Recommendation:** Print these out or keep them on a second monitor or in a digital notes app. Referring to them for a week or two is the fastest way to make these powerful commands second nature. Enjoy your new, highly efficient environment
