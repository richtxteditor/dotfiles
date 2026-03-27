return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Git Diff View" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git File History" },
    },
    opts = {
        enhanced_diff_hl = true,
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    },
}
