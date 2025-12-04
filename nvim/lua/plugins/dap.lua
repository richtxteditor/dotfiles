return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
                config = function()
                    local dapui = require("dapui")
                    dapui.setup()
                    local dap = require("dap")
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close()
                    end
                end,
            },
        },
        config = function()
            local dap = require("dap")

            -- C# debugger path fix for macOS
            -- THIS IS THE FIX: Only run if the adapter exists
            if dap.adapters.coreclr and vim.fn.has("mac") == 1 then
                dap.adapters.coreclr.args = {
                    "--interpreter=vscode",
                    "--connection=",
                }
            end

            -- Keybindings
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>du", require("dapui").toggle, { desc = "DAP: Toggle UI" })
        end,
    },
}
