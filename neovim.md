# My Personalized Neovim Command Sheet

**Your Leader Key:** `<Space>` (This is referred to as `<leader>` in the keymaps below)

## Essential Vim Motions & Edits (The Foundation)

*These commands are used in Normal Mode.*

| Keystroke(s) | Action |
| :--- | :--- |
| **`h j k l`** | Move cursor Left, Down, Up, Right. |
| **`w`** / **`b`** | Move forward/backward one **w**ord. |
| **`0`** / **`^`** | Jump to the start of the line / first non-whitespace character. |
| **`$`** | Jump to the end of the line. |
| **`gg`** / **`G`** | Go to the first / last line of the file. |
| **`%`** | Jump to the matching `()`, `[]`, or `{}`. |
| **`d`** | The **d**elete operator (e.g., `dw` to delete a word). |
| **`dd`** | Delete the current line. |
| **`c`** | The **c**hange operator (deletes and enters Insert mode). |
| **`cc`** | Change the current line. |
| **`y`** | The **y**ank (copy) operator (e.g., `yiw` to yank inner word). |
| **`yy`** | Yank (copy) the current line. |
| **`p`** | **P**aste after the cursor. |
| **`u`** / **`Ctrl+r`** | **U**ndo / **R**edo. |
| **`.`** | **Repeat the last change.** (Incredibly powerful!) |

## Window & File Management

*Your custom keymaps for managing the editor itself.*

| Keystroke | Action |
| :--- | :--- |
| **`<leader>w`** | **W**rite (save) the current file. |
| **`<leader>q`** | **Q**uit the current window. |
| **`<leader>Q`** | Force **Q**uit **A**ll windows, discarding all changes. |
| **`<Ctrl>+h/j/k/l`** | Navigate to the window Left/Down/Up/Right. |
| **`:sp`** / **`:vs`** | Create a horizontal / vertical **sp**lit. |

## File & Project Navigation (Your Plugins)

| Keystroke | Action & Plugin |
| :--- | :--- |
| **`<leader>fe`** | Toggle the **F**ile **E**xplorer (`nvim-tree`). |
| **`<leader>ff`** | **F**ind **F**iles in the project (`Telescope`). |
| **`<leader>fg`** | **F**ind by **G**rep (search for text content) in the project (`Telescope`). |
| **`<leader>fb`** | **F**ind **B**uffers (list of open files) (`Telescope`). |
| **`<leader>fo`** | **F**ind **O**ld Files (recently opened files) (`Telescope`). |

## Code Intelligence (LSP)

*These commands work when a Language Server is attached to the file.*

| Keystroke | Action |
| :--- | :--- |
| **`K`** | (Hover over a symbol) Show documentation and type information. |
| **`gd`** | **G**o to **D**efinition of the symbol under the cursor. |
| **`gr`** | **G**o to **R**eferences of the symbol under the cursor. |
| **`<leader>rn`** | **R**e**n**ame the symbol under the cursor across the project. |
| **`<leader>ca`** | Show available **C**ode **A**ctions (e.g., auto-import, fix error). |
| **`[d`** / **`]d`** | Go to the previous / next diagnostic (error, warning). |

## Formatting & Utility

| Keystroke | Action |
| :--- | :--- |
| **`<leader>cf`** | **C**ode **F**ormat the current file (`conform.nvim`). |
| **`<leader><space>`** | Clear the search highlight from the last search. |
| **`<leader>mp`** | Toggle **M**arkdown **P**review. |

## Plugin Management (`lazy.nvim`)

*These are `:commands` you type in Normal Mode.*

| Command | Action |
| :--- | :--- |
| **`:Lazy`** | Open the `lazy.nvim` dashboard to see all plugins. |
| **`:Lazy sync`** | **Sync** plugins: updates existing, installs new, removes old. **Your main update command.** |
| **`:Lazy update`** | Just **update** existing plugins. |
| **`:Lazy clean`** | Remove any disabled or uninstalled plugins. |
| **`:checkhealth`** | Run Neovim's diagnostic tool to check for issues. |
