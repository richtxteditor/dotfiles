return {
    {
        "williamboman/mason.nvim",
        opts = {
            ui = { border = "rounded" },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "folke/lazydev.nvim",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles or {}
            capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

            vim.diagnostic.config({
                severity_sort = true,
                update_in_insert = false,
                float = {
                    border = "rounded",
                    source = "if_many",
                },
                underline = true,
                virtual_text = {
                    spacing = 2,
                    source = "if_many",
                    prefix = "●",
                },
                signs = true,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, {
                            noremap = true,
                            silent = true,
                            buffer = bufnr,
                            desc = desc,
                        })
                    end

                    map("n", "gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
                    map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    map("n", "gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
                    map("n", "gr", vim.lsp.buf.references, "[G]oto [R]eferences")
                    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                    map("n", "<leader>ci", vim.lsp.buf.incoming_calls, "[C]all Hierarchy [I]ncoming")
                    map("n", "<leader>co", vim.lsp.buf.outgoing_calls, "[C]all Hierarchy [O]utgoing")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame Symbol")
                end,
            })

            vim.api.nvim_create_user_command("LspStatus", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local path = vim.api.nvim_buf_get_name(bufnr)
                local filetype = vim.bo[bufnr].filetype
                local root = vim.fs.root(path, { ".git" })
                local clients = vim.lsp.get_clients({ bufnr = bufnr })
                local client_names = vim.tbl_map(function(client)
                    return client.name
                end, clients)

                vim.print({
                    buffer = path,
                    filetype = filetype,
                    root = root,
                    clients = client_names,
                })
            end, { desc = "Show current buffer LSP status" })

            local managed_servers = {
                "pyright",
                "eslint",
                "html",
                "cssls",
                "tailwindcss",
                "jsonls",
                "yamlls",
                "lua_ls",
                "bashls",
                "clangd",
                "ts_ls",
                "sqlls",
                "djlsp",
            }

            for _, server in ipairs(managed_servers) do
                vim.lsp.config(server, {
                    capabilities = capabilities,
                })
            end

            vim.lsp.config("djlsp", {
                filetypes = { "htmldjango" },
                root_markers = { "manage.py" },
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.config("ts_ls", {
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                        },
                    },
                },
            })

            require("mason-lspconfig").setup({
                automatic_enable = false,
            })

            vim.lsp.enable(managed_servers)
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "windwp/nvim-autopairs",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered({ border = "rounded" }),
                    documentation = cmp.config.window.bordered({ border = "rounded" }),
                },
                mapping = {
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
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
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },
}
