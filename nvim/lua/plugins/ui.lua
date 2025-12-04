return {
    -- Indentation guides
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    -- Startup dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        opts = function()
            -- THIS IS THE FIX: We configure the dashboard and then RETURN it.
            local dashboard = require("alpha.themes.dashboard")

            -- Set up the dashboard buttons with icons
            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
                dashboard.button("n", "  New file", ":enew <CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
                dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
                dashboard.button("c", "  Configuration", ":e $MYVIMRC <CR>"),
                dashboard.button("q", "  Quit", ":qa <CR>"),
            }

            -- A simpler, cleaner header
            dashboard.section.header.val = {
                "  _   _                 _      ",
                " | \\ | |               | |     ",
                " |  \\| | ___  _ __ ___ | |__   ",
                " | . ` |/ _ \\| '_ ` _ \\| '_ \\  ",
                " | |\\  | (_) | | | | | | |_) | ",
                " |_| \\_|\\___/|_| |_| |_|_.__/  ",
                "                               ",
            }

            -- Add a footer with a useful tip
            dashboard.section.footer.val = "Tip: Press `Space f f` to find any file in your project."

            -- Return the configured dashboard options
            return dashboard.opts
        end,
    },
}
