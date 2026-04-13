return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = {
          char = "▏",
        },
        scope = {
          enabled = true,
        },
      })

      vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3a3f58" })
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#ff6a00" })
    end,
  },
}
