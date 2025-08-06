-- lua/plugins/telescope.lua

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      defaults = {
        layout_strategy = "vertical",
        border = true,
        prompt_prefix = " ",
        selection_caret = " ",
      },
    })
  end,
}