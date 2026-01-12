-- A helper function for creating keymaps for better readability
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Basic Editor Mappings
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit Window" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force Quit All" })

-- Clear search highlight
map("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlight" })

-- Telescope Mappings
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "[F]ind [F]iles" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "[F]ind by [G]rep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "[F]ind [B]uffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "[F]ind [H]elp Tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "[F]ind [O]ld Files" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "[F]ind [D]iagnostics" })

-- Formatting
map("n", "<leader>cf", "<cmd>ConformFormat<cr>", { desc = "[C]ode [F]ormat" })

-- Convenience Commands (Allow lowercase :lazy)
vim.cmd("cnoreabbrev <expr> lazy getcmdtype() == ':' && getcmdline() == 'lazy' ? 'Lazy' : 'lazy'")
