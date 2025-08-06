-- lua/plugins/lsp.lua

return {
  -- LSP Configuration & Plugins
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- LSP capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Setup Mason
      require("mason").setup({ ui = { border = "rounded" } })

      -- Define LSP on_attach function
      local on_attach = function(client, bufnr)
        -- Keymaps for LSP actions
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        map("n", "gr", vim.lsp.buf.references, "[G]oto [R]eferences")
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      end

      -- Configure which servers to install
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "eslint", "html", "cssls", "tailwindcss", "jsonls", "yamlls", "lua_ls", "bashls", "intelephense"},
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })
          end,
        },
      })
    end,
  },

  -- Autocompletion Engine: nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered({ border = "rounded" }),
          documentation = cmp.config.window.bordered({ border = "rounded" }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}