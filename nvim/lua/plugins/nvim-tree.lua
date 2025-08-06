-- lua/plugins/nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    require("nvim-tree").setup()

    -- Keymap to toggle NvimTree
    vim.keymap.set("n", "<leader>fe", "<cmd>NvimTreeToggle<cr>", { desc = "[F]ile [E]xplorer" })
  end,
}