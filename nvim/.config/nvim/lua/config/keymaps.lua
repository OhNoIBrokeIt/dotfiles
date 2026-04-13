-- Note: vim.g.mapleader is set in init.lua — do not set it here
local keymap = vim.keymap.set

-- ── File operations ───────────────────────────────────────
keymap("n", "<leader>w", "<cmd>w<cr>",   { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>",   { desc = "Quit" })
keymap("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- ── Explorer ──────────────────────────────────────────────
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer" })

-- ── Telescope ─────────────────────────────────────────────
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "Live grep" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     { desc = "Buffers" })
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",   { desc = "Help tags" })

-- ── Search ────────────────────────────────────────────────
keymap("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- ── Splits ────────────────────────────────────────────────
keymap("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
keymap("n", "<leader>sh", "<cmd>split<cr>",  { desc = "Horizontal split" })

-- ── Window navigation ─────────────────────────────────────
keymap("n", "<C-h>", "<C-w>h", { desc = "Move left" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move right" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move up" })

-- ── Terminal ──────────────────────────────────────────────
keymap("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })

-- ── Buffers ───────────────────────────────────────────────
keymap("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
keymap("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>",        { desc = "Delete buffer" })

-- ── Comments ──────────────────────────────────────────────
keymap("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
keymap("v", "<leader>/", "gc",  { remap = true, desc = "Toggle comment selection" })
