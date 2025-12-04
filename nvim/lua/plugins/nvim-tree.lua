-- lua/plugins/nvim-tree.lua

return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- Keymaps are defined here so Lazy can manage them
        keys = {
            {
                "<leader>e",
                "<cmd>NvimTreeToggle<cr>",
                desc = "Toggle File Explorer (NvimTree)",
            },
        },
        opts = {
            -- You can add your nvim-tree options here
            sort_by = "case_sensitive",
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = true,
            },
        },
    },
}
