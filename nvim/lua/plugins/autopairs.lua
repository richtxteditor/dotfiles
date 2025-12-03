return {
  'windwp/nvim-autopairs',
  -- Load this plugin whenever you enter Insert mode
  event = "InsertEnter",
  -- Make sure this loads after nvim-cmp to ensure the integration works
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local autopairs = require('nvim-autopairs')
    
    autopairs.setup({
      -- Makes autopairs smarter about where to insert pairs by checking syntax trees
      check_ts = true,
      -- Configure specific filetypes to ignore pairing inside certain syntax nodes
      ts_config = {
        lua = { 'string' }, -- Don't add pairs inside of strings in Lua
        javascript = { 'template_string' }, -- Don't add pairs inside of template strings in JS/TS
        java = false, -- Disable autopairs for Java
      },
    })

    -- This is the crucial part that integrates with nvim-cmp
    -- It tells cmp that autopairs will handle closing pairs after a completion is confirmed.
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  end,
}