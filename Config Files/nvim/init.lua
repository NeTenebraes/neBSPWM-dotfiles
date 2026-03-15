-- =========================================================
-- init.lua
-- Punto de entrada mínimo.
-- Mantener este archivo pequeño ayuda a depurar más fácil.
-- =========================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- nvim-tree reemplaza netrw; desactivarlo evita conflictos.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.lazy")
require("config.keymaps")
