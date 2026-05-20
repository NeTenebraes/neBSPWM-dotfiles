-- =========================================================
-- init.lua
-- Punto de entrada mínimo.
-- Mantener este archivo pequeño ayuda a depurar más fácil.
-- =========================================================

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
--vim.g.loaded_node_provider = 0

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- nvim-tree reemplaza netrw; desactivarlo evita conflictos.
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.lazy")
require("config.keymaps")
require("theme").setup()
