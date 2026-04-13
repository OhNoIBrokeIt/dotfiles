return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua        = { "stylua" },
          python     = { "isort", "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact  = { "prettier" },
          typescriptreact  = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          bash       = { "shfmt" },
        },
        format_on_save = {
          timeout_ms   = 1000,
          lsp_fallback = true,
        },
      })

      -- Renamed from <leader>f to <leader>cf (code format)
      -- Avoids ambiguity with <leader>ff (telescope find_files)
      vim.keymap.set("n", "<leader>cf", function()
        require("conform").format({
          async        = true,
          lsp_fallback = true,
        })
      end, { desc = "Format file" })
    end,
  },
}
