return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- fzf-native: significantly faster fuzzy finding
      -- requires make to be installed: sudo pacman -S make
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            ".git/",
            "node_modules/",
            "__pycache__/",
          },
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
            preview_width   = 0.55,
            width           = 0.90,
            height          = 0.85,
          },
          sorting_strategy = "ascending",
          prompt_prefix    = "󰍉  ",
          selection_caret  = " ",
          borderchars = {
            "─", "│", "─", "│",
            "╭", "╮", "╯", "╰",
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
        },
      })

      -- Load fzf extension if available
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
