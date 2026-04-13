local function reload_colors()
  -- Clear the cache for matugen-colors to get fresh values
  package.loaded["matugen-colors"] = nil
  local ok, colors = pcall(require, "matugen-colors")
  if not ok then
    vim.notify("Matugen: Failed to load colors", vim.log.levels.ERROR)
    return
  end

  -- Re-require the colorscheme plugin to apply new highlights
  pcall(function()
    local catppuccin_spec = require("plugins.colorscheme")
    local cat_opts = catppuccin_spec[1].opts

    -- Force update the color_overrides and highlight_overrides inside cat_opts
    -- Since cat_opts was defined with the old 'colors' table, we need to refresh it
    -- This is tricky because the file defining the spec also needs to be re-run
    package.loaded["plugins.colorscheme"] = nil
    catppuccin_spec = require("plugins.colorscheme")
    cat_opts = catppuccin_spec[1].opts

    require("catppuccin").setup(cat_opts)
    vim.cmd.colorscheme("catppuccin")

    -- Force transparency again
    local hl_groups = { "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }
    for _, group in ipairs(hl_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end

    -- Reload other UI components
    if package.loaded["lualine"] then
      package.loaded["plugins.lualine"] = nil
      local lualine_spec = require("plugins.lualine")
      require("lualine").setup(lualine_spec[1].opts)
    end

    if package.loaded["bufferline"] then
      package.loaded["plugins.bufferline"] = nil
      local bufferline_spec = require("plugins.bufferline")
      require("bufferline").setup(bufferline_spec[1].opts)
    end

    vim.notify("Matugen: Colors updated", vim.log.levels.INFO)
  end)
end

-- Watch for changes to matugen-colors.lua
local matugen_path = vim.fn.stdpath("config") .. "/lua/matugen-colors.lua"
local w = vim.loop.new_fs_event()

local function start_watch()
  w:start(matugen_path, {}, vim.schedule_wrap(function(err, fname, events)
    if err then
      vim.notify("Matugen Watch Error: " .. err, vim.log.levels.ERROR)
      return
    end
    -- Small delay to ensure the file is completely written
    vim.defer_fn(function()
      reload_colors()
    end, 200)
  end))
end

start_watch()
