return {
    -- Indentation guides
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    -- Startup dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        opts = function()
            local dashboard = require("alpha.themes.dashboard")

            -- sleek, slant style header
            dashboard.section.header.val = {
                [[    _   __                _         ]],
                [[   / | / /__  ____ _   __(_)___ ___ ]],
                [[  /  |/ / _ \/ __ \ | / / / __ `__ \]],
                [[ / /|  /  __/ /_/ / |/ / / / / / / /]],
                [[/_/ |_/\___/\____/|___/_/_/ /_/ /_/ ]],
            }

            -- Minimal, clean buttons
            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
                dashboard.button("n", "  New File", ":enew <CR>"),
                dashboard.button("r", "  Recent", ":Telescope oldfiles <CR>"),
                dashboard.button("g", "  Grep", ":Telescope live_grep <CR>"),
                dashboard.button("l", "󰒲  Lazy", ":Lazy <CR>"),
                dashboard.button("u", "󰚰  Update", ":Lazy sync <CR>"),
                dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
                dashboard.button("q", "  Quit", ":qa <CR>"),
            }

            -- Remove footer for a cleaner look
            dashboard.section.footer.val = ""

            return dashboard.opts
        end,
    },
}
