-- lua/plugins/markdown-preview.lua

return {
    {
        "iamcco/markdown-preview.nvim",
        -- This tells Lazy to load the plugin when you open a markdown file OR
        -- when you try to run one of these commands.
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },

        -- This command runs the first time you install the plugin.
        build = "cd app && npm install",

        -- This is the crucial part: define the keymaps here.
        keys = {
            {
                "<leader>mp",
                "<cmd>MarkdownPreviewToggle<cr>",
                desc = "[M]arkdown [P]review Toggle",
            },
            {
                "<leader>ms",
                "<cmd>MarkdownPreviewStop<cr>",
                desc = "[M]arkdown [P]review [S]top",
            },
        },
    },
}

