return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      -- McLaren themed UI for Mason
      vim.api.nvim_set_hl(0, "MasonNormal", { bg = "#0b0b0f" })
      vim.api.nvim_set_hl(0, "MasonHeader", { fg = "#000000", bg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlight", { fg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlightBlock", { fg = "#000000", bg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlightBlockBold", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "MasonMuted", { fg = "#8a8f98" })
      vim.api.nvim_set_hl(0, "MasonMutedBlock", { fg = "#cdd6f4", bg = "#1a1d26" })
      vim.api.nvim_set_hl(0, "MasonError", { fg = "#ff5f5f" })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local server_settings = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "bashls", "jsonls",
          "yamlls", "html", "cssls", "ts_ls",
        },
        handlers = {
          function(server_name)
            local config = server_settings[server_name] or {}
            config.capabilities = capabilities
            require("lspconfig")[server_name].setup(config)
          end,
        },
      })

      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end

          map("gd",         vim.lsp.buf.definition,    "Go to Definition")
          map("gD",         vim.lsp.buf.declaration,   "Go to Declaration")
          map("gr",         vim.lsp.buf.references,    "Go to References")
          map("gi",         vim.lsp.buf.implementation,"Go to Implementation")
          map("K",          vim.lsp.buf.hover,         "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename,        "Rename")
          map("<leader>ca", vim.lsp.buf.code_action,   "Code Action")
          map("<leader>fd", vim.diagnostic.open_float, "Floating Diagnostic")
          map("[d",         vim.diagnostic.goto_prev,  "Previous Diagnostic")
          map("]d",         vim.diagnostic.goto_next,  "Next Diagnostic")
        end,
      })
    end,
  },
}
