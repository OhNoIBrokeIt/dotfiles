return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "warning" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
        PERF = { icon = " ", color = "info", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      colors = {
        error = { "#ff5f5f" },
        warning = { "#ffb000" },
        info = { "#7dcfff" },
        hint = { "#8bd5ca" },
        test = { "#89b4fa" },
      },
    },
    config = function(_, opts)
      require("todo-comments").setup(opts)

      vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Todo Telescope" })
      vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo Trouble" })

      vim.api.nvim_set_hl(0, "TodoBgFIX", { fg = "#000000", bg = "#ff5f5f", bold = true })
      vim.api.nvim_set_hl(0, "TodoBgTODO", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "TodoBgNOTE", { fg = "#000000", bg = "#8bd5ca", bold = true })
      vim.api.nvim_set_hl(0, "TodoBgWARN", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "TodoBgPERF", { fg = "#000000", bg = "#7dcfff", bold = true })
      vim.api.nvim_set_hl(0, "TodoBgTEST", { fg = "#000000", bg = "#89b4fa", bold = true })
    end,
  },
}
