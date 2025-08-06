-- lua/plugins/theme.lua

return {
  -- Theme: Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false, -- Load theme on startup
    priority = 1000, -- Make sure it loads first
    config = function()
      require("kanagawa").setup({
        compile = true,
        undercurl = true,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        transparent = true,
        terminalColors = true,
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
      })
      vim.cmd("colorscheme kanagawa-wave")
    end,
  },

  -- Automatic Theme Switching based on macOS Dark Mode
  {
    "cormacrelf/dark-notify",
    config = function()
      require("dark_notify").run({
        schemes = {
          dark = { colorscheme = "kanagawa-wave" },
          light = { colorscheme = "kanagawa-lotus" },
        },
      })
    end,
  },
}