local ok, colors = pcall(require, "matugen-colors")
if not ok then
  colors = {
    base = "#11111b",
    surface = "#1e1e2e",
    surface_high = "#313244",
    on_surface = "#cdd6f4",
    primary = "#ff6a00",
    secondary = "#ffb000",
    error = "#f38ba8",
  }
end

local M = {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        indicator = { style = "icon", icon = "▎" },
        offsets = {
          {
            filetype = "NvimTree",
            text = "  File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
      highlights = {
        fill = { bg = colors.base },
        background = { fg = colors.on_surface, bg = colors.surface },
        buffer_selected = { fg = colors.on_surface, bg = colors.surface_high, bold = true },
        indicator_selected = { fg = colors.primary, bg = colors.surface_high },
        separator = { fg = colors.base, bg = colors.surface },
        separator_selected = { fg = colors.base, bg = colors.surface_high },
        modified = { fg = colors.secondary, bg = colors.surface },
        modified_selected = { fg = colors.secondary, bg = colors.surface_high },
        error = { fg = colors.error, bg = colors.surface },
        error_selected = { fg = colors.error, bg = colors.surface_high, bold = true },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
    end,
  },
}

return M
