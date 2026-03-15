-- =========================================================
-- options.lua
-- Opciones base del editor.
-- Solo comportamiento general; nada de plugins aquí.
-- =========================================================

local opt = vim.opt

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.showmode = false
opt.pumblend = 6
opt.winblend = 6
opt.background = "dark"

-- Navegación / ventanas
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Edición
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

-- Sistema
opt.clipboard = "unnamedplus"
opt.updatetime = 250

vim.cmd("syntax on")
