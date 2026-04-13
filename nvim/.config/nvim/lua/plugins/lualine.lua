local ok, colors = pcall(require, "matugen-colors")
if not ok then
  colors = {
    base = "#11111b",
    surface = "#1e1e2e",
    on_surface = "#cdd6f4",
    primary = "#ff6a00",
    secondary = "#ffb000",
    tertiary = "#89b4fa",
    error = "#f38ba8",
    outline = "#7f849c",
  }
end

local matugen_theme = {
  normal = {
    a = { fg = colors.base, bg = colors.primary, gui = "bold" },
    b = { fg = colors.on_surface, bg = colors.surface },
    c = { fg = colors.on_surface, bg = "NONE" },
  },
  insert = {
    a = { fg = colors.base, bg = colors.secondary, gui = "bold" },
    b = { fg = colors.on_surface, bg = colors.surface },
    c = { fg = colors.on_surface, bg = "NONE" },
  },
  visual = {
    a = { fg = colors.base, bg = colors.tertiary, gui = "bold" },
    b = { fg = colors.on_surface, bg = colors.surface },
    c = { fg = colors.on_surface, bg = "NONE" },
  },
  replace = {
    a = { fg = colors.base, bg = colors.error, gui = "bold" },
    b = { fg = colors.on_surface, bg = colors.surface },
    c = { fg = colors.on_surface, bg = "NONE" },
  },
  command = {
    a = { fg = colors.base, bg = colors.secondary, gui = "bold" },
    b = { fg = colors.on_surface, bg = colors.surface },
    c = { fg = colors.on_surface, bg = "NONE" },
  },
  inactive = {
    a = { fg = colors.outline, bg = colors.base, gui = "bold" },
    b = { fg = colors.outline, bg = colors.base },
    c = { fg = colors.outline, bg = colors.base },
  },
}

local M = {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = matugen_theme,
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "│", right = "│" },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "", color = { fg = colors.primary, gui = "bold" } },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            diff_color = {
              added    = { fg = colors.secondary },
              modified = { fg = colors.tertiary },
              removed  = { fg = colors.error },
            },
          },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_lsp" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            diagnostics_color = {
              error = { fg = colors.error },
              warn  = { fg = colors.tertiary },
              info  = { fg = colors.primary },
              hint  = { fg = colors.secondary },
            },
          },
          { "encoding", color = { fg = colors.outline } },
          { "fileformat", symbols = { unix = " ", dos = " ", mac = " " }, color = { fg = colors.outline } },
          { "filetype" },
        },
        lualine_y = { { "progress", color = { fg = colors.primary, gui = "bold" } } },
        lualine_z = { { "location" } },
      },
      extensions = { "nvim-tree", "lazy", "mason", "trouble" },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
}

return M
