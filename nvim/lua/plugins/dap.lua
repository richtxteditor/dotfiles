-- lua/plugins/dap.lua

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text", -- Inline variable values
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- 1. SETUP MASON-DAP
            require("mason-nvim-dap").setup({
                -- Ensure these are installed
                ensure_installed = { "python", "delve", "codelldb" },

                -- HANDLERS: This is where we fix the path issues
                handlers = {
                    -- Default handler for things like Python
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,

                    -- Specific handler for C/C++/Rust (CodeLLDB)
                    -- We explicitly point to the executable to fix the health check error
                    codelldb = function(config)
                        config.adapters = {
                            type = "server",
                            port = "${port}",
                            executable = {
                                command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                                args = { "--port", "${port}" },
                            },
                        }
                        require("mason-nvim-dap").default_setup(config)
                    end,

                    -- Specific handler for Go (Delve)
                    delve = function(config)
                        config.adapters = {
                            type = "server",
                            port = "${port}",
                            executable = {
                                command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
                                args = { "dap", "-l", "127.0.0.1:${port}" },
                            },
                        }
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })

            -- 2. SETUP VIRTUAL TEXT
            require("nvim-dap-virtual-text").setup({})

            -- 3. SETUP UI
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks",      size = 0.25 },
                            { id = "watches",     size = 0.25 },
                        },
                        size = 40,
                        position = "left",
                    },
                    {
                        elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
                        size = 0.25,
                        position = "bottom",
                    },
                },
                controls = {
                    enabled = true,
                    element = "repl",
                    icons = {
                        pause = "",
                        play = "",
                        step_into = "",
                        step_over = "",
                        step_out = "",
                        step_back = "",
                        run_last = "↻",
                        terminate = "",
                    },
                },
            })

            -- Auto-open UI listeners
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            -- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            -- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- 4. KEYBINDINGS
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<F6>", function() require("dap").terminate(); require("dapui").close() end, { desc = "DAP: Stop" })
            vim.keymap.set("n", "<F8>", dap.step_out, { desc = "DAP: Step Out" })
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
            vim.keymap.set('n', '<leader>de', require('dapui').eval, { desc = "DAP: Evaluate" })

            -- 5. LOAD LAUNCH.JSON
            require("dap.ext.vscode").load_launchjs(nil, {
                ["codelldb"] = { "c", "cpp", "rust" },
                ["coreclr"] = { "cs" },
            })
        end,
    },
}
