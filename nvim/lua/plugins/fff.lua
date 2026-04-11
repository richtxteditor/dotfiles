return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    -- this will download prebuild binary or try to use existing rustup toolchain to build from source
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    -- (optional)
    debug = {
      enabled = true,
      show_scores = true,
    },
  },
  lazy = true,
  cmd = {
    "FFFFind",
    "FFFScan",
    "FFFRefreshGit",
    "FFFClearCache",
    "FFFHealth",
    "FFFDebug",
    "FFFOpenLog",
  },
  keys = {
    {
      "<leader>ff",
      function() require('fff').find_files() end,
      desc = 'FFFind files',
    },
    {
      "<leader>fg",
      function() require('fff').live_grep() end,
      desc = 'LiFFFe grep',
    },
    {
      "<leader>fz",
      function() require('fff').live_grep({
        grep = {
          modes = { 'fuzzy', 'plain' }
        }
      }) end,
      desc = 'Live fffuzy grep',
    },
    {
      "<leader>fc",
      function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
      desc = 'Search current word',
    },
  }
}
