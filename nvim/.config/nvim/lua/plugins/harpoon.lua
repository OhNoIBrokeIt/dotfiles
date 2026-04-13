return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Core harpoon binds
      vim.keymap.set("n", "<leader>a",  function() harpoon:list():add() end,
        { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon menu" })

      -- Quick file select
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

      -- Telescope integration — browse harpoon files in telescope
      -- Note: uses <leader>ht to avoid conflict with <leader>fh (help_tags)
      vim.keymap.set("n", "<leader>ht", function()
        local conf       = require("telescope.config").values
        local file_paths = {}
        for _, item in ipairs(harpoon:list().items) do
          table.insert(file_paths, item.value)
        end
        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon Files",
          finder       = require("telescope.finders").new_table({ results = file_paths }),
          previewer    = conf.file_previewer({}),
          sorter       = conf.generic_sorter({}),
        }):find()
      end, { desc = "Harpoon files (telescope)" })
    end,
  },
}
