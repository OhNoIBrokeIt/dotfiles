return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
      focus = true,
      use_diagnostic_signs = true,
      warn_no_results = false,
      open_no_results = true,
      icons = {
        indent = {
          top = "│ ",
          middle = "├╴",
          last = "└╴",
          fold_open = " ",
          fold_closed = " ",
          ws = "  ",
        },
      },
    },
    config = function(_, opts)
      require("trouble").setup(opts)

      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
      vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols" })
      vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP definitions/references" })
      vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list" })
      vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })

      vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "#0b0b0f" })
      vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "#0b0b0f" })
      vim.api.nvim_set_hl(0, "TroubleTitle", { fg = "#000000", bg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "TroubleCount", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "TroubleIconDirectory", { fg = "#ffb000" })
      vim.api.nvim_set_hl(0, "TroubleIconFile", { fg = "#e5e5e5" })
      vim.api.nvim_set_hl(0, "TroubleIndent", { fg = "#3a3f58" })
      vim.api.nvim_set_hl(0, "TroubleFoldIcon", { fg = "#ff6a00" })
    end,
  },
}
