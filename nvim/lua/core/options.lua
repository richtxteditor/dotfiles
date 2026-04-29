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

-- Neovim 0.12 starts the built-in Treesitter highlighter directly for markdown
-- buffers and LSP markdown documentation floats. That path currently trips a
-- 'range' nil error in markdown injections, so block only markdown starts.
do
    local disabled_ts_filetypes = {
        markdown = true,
        markdown_inline = true,
    }

    if not vim.g.dotfiles_markdown_ts_guard then
        vim.g.dotfiles_markdown_ts_guard = true
        local treesitter_start = vim.treesitter.start

        vim.treesitter.start = function(bufnr, lang)
            if disabled_ts_filetypes[lang] then
                return
            end

            local ok, filetype = pcall(function()
                return vim.bo[bufnr or 0].filetype
            end)

            if ok and disabled_ts_filetypes[filetype] then
                return
            end

            return treesitter_start(bufnr, lang)
        end
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "markdown_inline" },
        callback = function(ev)
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(ev.buf) then
                    pcall(vim.treesitter.stop, ev.buf)
                end
            end)
        end,
    })
end
