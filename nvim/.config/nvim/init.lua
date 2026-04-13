-- Disable netrw before anything else — prevents conflict with nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set leaders FIRST before lazy loads any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load config
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
