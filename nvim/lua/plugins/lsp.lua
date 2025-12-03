-- lua/plugins/lsp.lua

return {
    -- LSP Configuration & Plugins
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            require("mason").setup({ ui = { border = "rounded" } })

            local on_attach = function(client, bufnr)
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
                end
                map("n", "gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
                map("n", "gr", vim.lsp.buf.references, "[G]oto [R]eferences")
                map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                map("n", "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
            end

            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "eslint", "html", "cssls", "tailwindcss", "jsonls", "yamlls", "lua_ls", "bashls", "intelephense" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({ on_attach = on_attach, capabilities = capabilities })
                    end,
                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { 'vim' } },
                                    workspace = { checkThirdParty = false },
                                    telemetry = { enable = false },
                                },
                            },
                        })
                    end,
                },
            })
        end,
    },

    -- Autocompletion Engine: nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path", "windwp/nvim-autopairs",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                window = {
                    completion = cmp.config.window.bordered({ border = "rounded" }),
                    documentation = cmp.config.window.bordered({ border = "rounded" }),
                },

                -- THIS IS THE CORRECTED AND ENHANCED MAPPING TABLE
                mapping = {
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        -- This is the new, robust check
                        local col = vim.fn.col('.') - 1
                        if cmp.visible() then
                            cmp.select_next_item()
                            -- Check if the cursor is inside a pair and the next character is the closing pair
                        elseif col > 0 and vim.fn.getline('.'):sub(col + 1, col + 1):match('[)}\\]\'"]') then
                            -- If so, just jump out of the pair
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right>', true, false, true), 'n',
                                false)
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" }, { name = "luasnip" },
                    { name = "buffer" }, { name = "path" },
                }),
            })
        end,
    },
}

