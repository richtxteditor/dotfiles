return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            -- List of language parsers to install
            ensure_installed = {
                "lua", "vim", "vimdoc", "python", "javascript", "typescript", "tsx",
                "html", "css", "json", "yaml", "bash", "markdown", "markdown_inline",
                "php", "java", "c", "cpp", "rust",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })

        -- This is the separate setup for the context plugin
        require("treesitter-context").setup({
            enable = true,  -- Enable this plugin
            max_lines = 0,  -- 0 means no limit
            trim_scope = "inner", -- Or "outer"
        })
    end,
    -- We also need to declare the context plugin as a dependency
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
    },
}
