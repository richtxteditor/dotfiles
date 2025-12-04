return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- 1. The Installer
            "williamboman/mason.nvim",
            -- 2. The Bridge (Mason -> DAP)
            "jay-babu/mason-nvim-dap.nvim",
            -- 3. The UI
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            -- 4. Virtual Text (See variable values inline in code!)
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- SETUP UI
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- SETUP VIRTUAL TEXT
            require("nvim-dap-virtual-text").setup({})

            -- SETUP MASON-DAP (The Magic Part)
            require("mason-nvim-dap").setup({
                -- Automatic installation of debuggers you commonly use
                ensure_installed = {
                    "python",   -- installs debugpy
                    "delve",    -- installs delve (for Go)
                    "codelldb", -- installs codelldb (for Rust/C++)
                },

                -- AUTOMATIC HANDLERS
                -- This function runs for every debugger installed by Mason.
                -- It sets up the default configuration so you don't have to.
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,

                    -- Custom override for C# (Netcoredbg) on Mac
                    -- (Example of how to handle edge cases)
                    coreclr = function(config)
                        if vim.fn.has("mac") == 1 then
                            config.adapters = {
                                type = "executable",
                                command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg",
                                args = { "--interpreter=vscode" }
                            }
                        end
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })

            -- KEYBINDINGS
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })

            -- LOAD LAUNCH.JSON
            -- If you have a .vscode/launch.json in your project, load it.
            require("dap.ext.vscode").load_launchjs(nil, {
                -- Map language names to filetypes if they differ
                ["pwa-node"] = { "javascript", "typescript" },
                ["cppdbg"] = { "c", "cpp" },
                ["coreclr"] = { "cs" },
            })
        end,
    },
}
