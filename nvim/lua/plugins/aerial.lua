return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Toggle Symbol Outline" },
    },
    opts = {
        backends = { "markdown", "lsp", "treesitter", "man" },
        layout = {
            min_width = 30,
            default_direction = "prefer_right",
        },
        show_guides = true,
        filter_kind = false,
    },
}
