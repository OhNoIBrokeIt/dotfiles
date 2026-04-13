local ok, colors = pcall(require, "matugen-colors")
if not ok then
  -- Fallback if matugen-colors.lua doesn't exist yet
  colors = {
    base = "#1c110c",
    on_surface = "#f6ddd4",
    primary = "#ffb596",
    secondary = "#c4d000",
    tertiary = "#ffb596",
    error = "#ffb4ab",
    outline = "#a88a7f",
    surface = "#1c110c",
    surface_high = "#594238",
  }
end

local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      integrations = {
        telescope = true,
        nvimtree = true,
        treesitter = true,
        noice = true,
        notify = true,
        dashboard = true,
        which_key = true,
        harpoon = true,
        gitsigns = true,
        indent_blankline = {
          enabled = true,
          scope_color = "mauve",
        },
      },
      color_overrides = {
        mocha = {
          -- Matugen-driven Colors
          rosewater = colors.on_surface,
          flamingo = colors.error,
          pink = colors.tertiary,
          mauve = colors.primary,
          red = colors.error,
          maroon = colors.error,
          peach = colors.primary,
          yellow = colors.tertiary,
          green = colors.secondary,
          teal = colors.primary,
          sky = colors.primary,
          sapphire = colors.primary,
          blue = colors.secondary,
          lavender = colors.primary,
          base = colors.base,
          mantle = colors.base,
          crust = colors.base,
        },
      },
      highlight_overrides = {
        mocha = function(cp)
          return {
            -- Core UI (Using Matugen Palette)
            NormalFloat = { bg = colors.base },
            FloatBorder = { fg = colors.primary, bg = colors.base },
            FloatTitle = { fg = colors.base, bg = colors.primary, bold = true },

            CursorLine = { bg = colors.surface },
            Visual = { bg = colors.surface_high },
            Search = { fg = colors.base, bg = colors.primary, bold = true },
            IncSearch = { fg = colors.base, bg = colors.secondary, bold = true },

            LineNr = { fg = colors.outline },
            CursorLineNr = { fg = colors.primary, bold = true },

            -- Diagnostics
            DiagnosticError = { fg = colors.error },
            DiagnosticWarn = { fg = colors.tertiary },
            DiagnosticInfo = { fg = colors.secondary },
            DiagnosticHint = { fg = colors.on_surface },

            -- Signs
            DiagnosticSignError = { fg = colors.error, bg = "NONE" },
            DiagnosticSignWarn = { fg = colors.tertiary, bg = "NONE" },
            DiagnosticSignInfo = { fg = colors.secondary, bg = "NONE" },
            DiagnosticSignHint = { fg = colors.on_surface, bg = "NONE" },

            -- Completion menu
            Pmenu = { fg = colors.on_surface, bg = colors.base },
            PmenuSel = { fg = colors.base, bg = colors.primary, bold = true },
            PmenuSbar = { bg = colors.surface },
            PmenuThumb = { bg = colors.primary },

            CmpItemAbbrMatch = { fg = colors.primary, bold = true },
            CmpItemAbbrMatchFuzzy = { fg = colors.primary, bold = true },
            CmpItemMenu = { fg = colors.outline, italic = true },

            -- Telescope
            TelescopeNormal = { bg = colors.base },
            TelescopeBorder = { fg = colors.primary, bg = colors.base },
            TelescopeTitle = { fg = colors.base, bg = colors.primary, bold = true },
            TelescopePromptNormal = { bg = colors.surface },
            TelescopePromptBorder = { fg = colors.tertiary, bg = colors.surface },
            TelescopePromptTitle = { fg = colors.base, bg = colors.tertiary, bold = true },
            TelescopeResultsNormal = { bg = colors.base },
            TelescopePreviewNormal = { bg = colors.base },
            TelescopeSelection = { bg = colors.surface_high, bold = true },
            TelescopeSelectionCaret = { fg = colors.primary, bg = colors.surface_high },

            -- NvimTree
            NvimTreeNormal = { bg = "NONE" },
            NvimTreeNormalFloat = { bg = colors.base },
            NvimTreeCursorLine = { bg = colors.surface },
            NvimTreeFolderIcon = { fg = colors.primary },
            NvimTreeOpenedFolderName = { fg = colors.primary, bold = true },

            -- Indent guides
            IblIndent = { fg = colors.surface },
            IblScope = { fg = colors.primary, bold = true },

            -- WhichKey
            WhichKey = { fg = colors.primary, bold = true },
            WhichKeyDesc = { fg = colors.on_surface },
            WhichKeyGroup = { fg = colors.secondary },
            WhichKeySeparator = { fg = colors.outline },

            -- General Title
            Title = { fg = colors.primary, bold = true },
          }
        end,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")

      -- Force transparency after colorscheme load
      local hl_groups = { "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }
      for _, group in ipairs(hl_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE" })
      end
    end,
  },
}

return M
