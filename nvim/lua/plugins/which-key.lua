return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500 -- Wait 500ms before showing the popup
    end,
    opts = {},
  },
}
