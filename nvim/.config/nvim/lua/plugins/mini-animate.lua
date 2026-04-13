return {
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
      require("mini.animate").setup({
        cursor = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 80, unit = "total" }),
        },
        scroll = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 100, unit = "total" }),
        },
        resize = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 80, unit = "total" }),
        },
        open = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 80, unit = "total" }),
        },
        close = {
          enable = true,
          timing = require("mini.animate").gen_timing.linear({ duration = 80, unit = "total" }),
        },
      })
    end,
  },
}
