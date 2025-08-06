-- lua/core/keymaps.lua

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

-- Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus Left Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus Right Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus Upper Window" })

-- Telescope Mappings
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "[F]ind [F]iles" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "[F]ind by [G]rep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "[F]ind [B]uffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "[F]ind [H]elp Tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "[F]ind [O]ld Files" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "[F]ind [D]iagnostics" })

-- Markdown Preview Mappings
map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "[M]arkdown [P]review Toggle" })
map("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "[M]arkdown [P]review [S]top" })

-- Formatting
map("n", "<leader>cf", "<cmd>ConformFormat<cr>", { desc = "[C]ode [F]ormat" })