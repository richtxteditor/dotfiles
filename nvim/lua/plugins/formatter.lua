-- lua/plugins/formatter.lua

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- Run formatter before saving
  cmd = { "ConformInfo" },
  config = function()
    require("conform").setup({
      -- Configure formatters for different file types
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        -- Add the configuration for PHP
        php = { "php-cs-fixer" }, -- <<<--- PHP FORMATTER
      },
      -- Optional: Run formatter automatically on save
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}