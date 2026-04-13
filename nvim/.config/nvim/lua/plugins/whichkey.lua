return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "format/find" },
        { "<leader>h", group = "harpoon" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "trouble/lists" },
        { "<leader>s", group = "search/symbols" },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },
}
