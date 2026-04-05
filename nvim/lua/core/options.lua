local opt = vim.opt -- for conciseness

-- Core Behavior
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.mouse = "a"               -- Enable mouse support

-- UI
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.signcolumn = "yes"    -- Always show the sign column
opt.cursorline = true     -- Highlight the current line
opt.termguicolors = true  -- Enable 24-bit RGB colors
opt.showmode = false      -- Hide the default mode indicator
opt.splitright = true     -- V-splits open to the right
opt.splitbelow = true     -- H-splits open to the bottom
opt.wrap = false          -- Disable line wrapping

-- Searching
opt.ignorecase = true -- Case-insensitive searching
opt.smartcase = true  -- Case-sensitive if the pattern has uppercase letters
opt.hlsearch = true   -- Highlight search results
opt.incsearch = true  -- Show search results incrementally

-- Performance & Behavior
opt.updatetime = 250  -- Faster completion
opt.timeoutlen = 500  -- 500ms timeout for leader key mappings
opt.ttimeoutlen = 10  -- An instant 10ms timeout for the Escape key
opt.undofile = true   -- Enable persistent undo
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Indentation
opt.tabstop = 4        -- Number of spaces a tab is equal to
opt.shiftwidth = 4     -- Number of spaces for indentation
opt.softtabstop = 4    -- Number of spaces for tab/backspace
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Enable smart auto-indenting

-- Display invisible characters
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Keeps cursor 8 lines away from screen edges (better context)
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Per-filetype keyword lookup (K key fallback when no LSP hover)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function() vim.bo.keywordprg = "pydoc" end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "ruby",
    callback = function() vim.bo.keywordprg = "ri" end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "bash", "zsh" },
    callback = function() vim.bo.keywordprg = ":Man" end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function() vim.bo.keywordprg = ":Man 3" end,
})

-- Neovim 0.12 auto-enables built-in treesitter highlighting for markdown,
-- which hits a 'range' nil error. Stop it immediately after the filetype is set.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "markdown_inline" },
    callback = function(ev)
        vim.treesitter.stop(ev.buf)
    end,
})
