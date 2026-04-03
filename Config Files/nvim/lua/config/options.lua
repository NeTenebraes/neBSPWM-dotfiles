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

-- =========================================================
      -- === NUEVO: CONFIGURACIÓN DE PLEGADO (FOLDING) ===
      -- Esto permite colapsar bloques de código (if, for, funciones)
      -- de forma inteligente usando el parser de Treesitter.
      -- =========================================================
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr   = "v:treesitter#foldexpr()"
      vim.opt.foldenable = false -- Evita que el código se abra plegado por defecto
      vim.opt.foldlevel  = 99    -- Abre todos los niveles de plegado inicialmente

vim.cmd("syntax on")
