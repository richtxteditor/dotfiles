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
opt.timeoutlen = 2000 -- A comfortable 2-second timeout for your <leader> mappings
opt.ttimeoutlen = 10  -- An instant 10ms timeout for the Escape key
opt.undofile = true   -- Enable persistent undo

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
