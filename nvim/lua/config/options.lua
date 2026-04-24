-- lua/config/options.lua

-- Python provider (used by Neovim + remote plugins)
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/nvim/bin/python3")

-- Disable unused language providers to avoid warnings and startup work
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- backspace
local opt = vim.opt -- for conciseness

opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
-- cursor line
-- opt.cursorline = true -- highlight the current cursor line

-- appearance
opt.termguicolors = true

-- line wrapping
opt.wrap = false -- disable line wrapping

-- tabs & indentation
opt.tabstop = 4 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

opt.undofile = true -- persistent undo across sessions
