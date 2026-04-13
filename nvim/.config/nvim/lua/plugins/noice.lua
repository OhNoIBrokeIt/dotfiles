return {
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        background_colour = "#0b0b0f",
        render = "compact",
        stages = "fade",
        timeout = 3000,
        max_width = 50,
        icons = {
          ERROR = " ",
          WARN  = " ",
          INFO  = " ",
          DEBUG = " ",
          TRACE = "✎ ",
        },
      })

      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          progress = { enabled = true },
          hover = { enabled = true },
          signature = { enabled = true },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          format = {
            cmdline     = { pattern = "^:",      icon = " ", lang = "vim",   title = "" },
            search_down = { pattern = "^/",      icon = " ", lang = "regex", title = "" },
            search_up   = { pattern = "^%?",     icon = " ", lang = "regex", title = "" },
            filter      = { pattern = "^:%s*!",  icon = " ", lang = "bash",  title = "" },
            lua         = { pattern = "^:%s*lua%s+", icon = " ", lang = "lua", title = "" },
            help        = { pattern = "^:%s*he?l?p?%s", icon = "󰋖 ",          title = "" },
          },
        },
        views = {
          cmdline_popup = {
            position = { row = "40%", col = "50%" },
            size = { width = 60, height = "auto" },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "NoiceCmdlinePopup",
                FloatBorder = "NoiceCmdlinePopupBorder",
              },
            },
          },
          popupmenu = {
            relative = "editor",
            position = { row = "40%", col = "50%" },
            size = { width = 60, height = 10 },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
        },
        routes = {
          -- suppress "written" messages
          { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
          -- suppress search count
          { filter = { event = "msg_show", kind = "search_count" },       opts = { skip = true } },
        },
      })

      -- McLaren highlight overrides
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup",           { bg = "#0b0b0f", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder",     { fg = "#ff6a00" })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon",            { fg = "#ff6a00" })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch",      { fg = "#ffb000" })
      vim.api.nvim_set_hl(0, "NoiceConfirm",                { bg = "#0b0b0f" })
      vim.api.nvim_set_hl(0, "NoiceConfirmBorder",          { fg = "#ff6a00" })

      vim.notify = require("notify")
    end,
  },
}
