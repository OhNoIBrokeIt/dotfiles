local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.completeopt = "menu,menuone,noselect"
opt.laststatus = 3
opt.pumblend = 10
opt.winblend = 10

-- Quality of life additions
opt.fileencoding = "utf-8"        -- explicit UTF-8 encoding
opt.conceallevel = 0              -- show `` in markdown files
opt.iskeyword:append("-")         -- treat hyphenated-words as one word
opt.shortmess:append("c")         -- don't show completion menu messages
opt.virtualedit = "block"         -- free cursor in visual block mode
