return {
    {
        "echasnovski/mini.icons",
        version = false, -- Use the latest version
        config = function()
            require("mini.icons").setup()

            -- This is the magic line. It lets mini.icons overwrite
            -- nvim-web-devicons, so you don't need to change other plugins.
            require("mini.icons").mock_nvim_web_devicons()
        end,
    },
}
