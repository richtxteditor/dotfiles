# Neovim Cheat Sheet

**Leader Key:** `<Space>`

## 1. Core Mappings (Your Custom Shortcuts)

| Action | Keybinding |
| :--- | :--- |
| **Save File** | `<leader>w` |
| **Quit Window** | `<leader>q` |
| **Force Quit All** | `<leader>Q` |
| **Clear Highlight** | `<leader><space>` |
| **Open Lazygit** | `<leader>gg` |
| **Format Code** | `<leader>cf` |

## 2. Navigation (Getting Around)

| Action | Keybinding |
| :--- | :--- |
| **Basic Movement** | `h`, `j`, `k`, `l` |
| **Jump by Lines** | `5j` |
| **Word Movement** | `w`, `b`, `e` |
| **File Start/End** | `gg` / `G` |
| **Go Back / Forward** | `Ctrl` + `o` / `Ctrl` + `i` |

## 3. Editing (Changing Text)

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Change Inner Word** | `ciw` | Delete word under cursor and enter Insert mode. |
| **Delete Till Char** | `dt"` | Delete everything on the line until the next quote. |
| **Undo / Redo** | `u` / `Ctrl` + `r`| Persists across sessions. |
| **Repeat Last Action**| `.` (dot) | Repeats your last change (e.g., a `ciw` or `dd`). |

## 4. Windows, Tabs & Layout

| Action | Command / Keys |
| :--- | :--- |
| **Vertical Split** | `:vsp` / `Ctrl+w, v` |
| **Horizontal Split**| `:sp` / `Ctrl+w, s` |
| **Close ALL Others** | `:only` |
| **Focus Pane** | `Ctrl` + `h/j/k/l`|

## 5. Plugin Integrations (The Complete List)

### Telescope (Fuzzy Finder)

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Find Files** | `<leader>ff` | Find Files |
| **Live Grep (Text)**| `<leader>fg` | Find Text |
| **Find Buffers**| `<leader>fb` | Find Buffers |
| **Find Help Tags** | `<leader>fh` | Find Help Tags |
| **Find Old Files** | `<leader>fo` | Find Old Files |
| **Find Diagnostics**| `<leader>fd` | Find Diagnostics |
| **In Telescope Menu**| `Ctrl+v` / `Ctrl+x` | Open selection in a vertical/horizontal split. |

### Nvim-Tree (File Explorer)

| Action | Keybinding |
| :--- | :--- |
| **Toggle Tree** | `<leader>e` |
| **Open File** | `Enter` or `o` |
| **Open in V-Split** | `v` |
| **Open in H-Split** | `s` |
| **Create File/Dir** | `a` |
| **Rename File** | `r` |
| **Delete File** | `d` |
| **Copy / Paste** | `c` / `p` |

### Autocomplete & Snippets (nvim-cmp)

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Navigate Menu** | `Ctrl+n` / `Ctrl+p` | Select next/previous item in the popup menu. |
| **Confirm Completion**| `Enter` or `Tab` | Accept the selected suggestion. |
| **Expand Snippet** | `Tab` or `Enter` | If a snippet is selected, this will expand it. |
| **Close Menu** | `Ctrl+e` | Close the completion menu without accepting. |

### Git Integration (Gitsigns)

*Gitsigns* adds indicators in the left gutter for added (`+`), modified (`~`), and removed (`-`) lines.

| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Stage Hunk** | `<leader>hs` | Stage the current block of changes (`hunk`). |
| **Preview Hunk** | `<leader>hp` | Show a floating window with the diff of the current hunk. |
| **Undo Hunk** | `<leader>hu` | Revert the changes in the current hunk. |
| **Next / Prev Hunk**| `]c` / `[c` | Jump between changed hunks in the file. |

### LSP (Language Intelligence)

| Action | Keybinding |
| :--- | :--- |
| **Hover Docs** | `K` |
| **Go to Definition** | `gd` |
| **Rename Symbol** | `gr` |
| **Code Actions** | `<leader>ca` |

## Markdown Preview

| Action | Keybinding |
| :--- | :--- |
| **Toggle Preview** | `<leader>mp` |
| **Stop Preview** | `<leader>ms` |
