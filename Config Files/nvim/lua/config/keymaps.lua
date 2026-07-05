local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function nmap(lhs, rhs, desc)
  map("n", lhs, rhs, { silent = true, desc = desc })
end

local function vmap(lhs, rhs, desc)
  map("v", lhs, rhs, { silent = true, desc = desc })
end

local function imap(lhs, rhs, desc)
  map("i", lhs, rhs, { silent = true, desc = desc })
end

-- =========================================================
-- NAVEGACIÓN
-- =========================================================
nmap("<leader>e", function() Snacks.explorer() end, "Explorer: Toggle")
nmap("<leader>ff", function() Snacks.picker.files() end, "Find: Files")
nmap("<leader>fg", function() Snacks.picker.grep() end, "Find: Grep")
nmap("<leader>fb", function() Snacks.picker.buffers() end, "Find: Buffers")

-- =========================================================
-- ARCHIVOS / BUFFER
-- =========================================================
nmap("<leader>w", "<cmd>w<CR>", "File: Write")
nmap("<leader>q", "<cmd>q<CR>", "Window: Quit")
nmap("<leader>ve", "<cmd>edit $MYVIMRC<CR>", "Vim: Edit init.lua")

nmap("<leader>bn", "<cmd>bnext<CR>", "Buffer: Next")
nmap("<leader>bp", "<cmd>bprevious<CR>", "Buffer: Previous")
nmap("<Tab>", "<cmd>bnext<CR>", "Buffer: Next")
nmap("<S-Tab>", "<cmd>bprevious<CR>", "Buffer: Previous")

-- Borrado inteligente: Evita romper la maquetación visual de tus paneles abiertos
nmap("<leader>bd", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then bufremove.delete(0, false) else vim.cmd("bdelete") end
end, "Buffer: Delete Safely")

-- =========================================================
-- FORMATO / LSP
-- =========================================================
nmap("<leader>f", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end, "Format: File")

nmap("gK", vim.lsp.buf.hover, "LSP: Hover Docs")
nmap("gd", vim.lsp.buf.definition, "LSP: Definition")
nmap("gr", vim.lsp.buf.references, "LSP: References")
nmap("<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
nmap("<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")

-- =========================================================
-- CLIPBOARD / YANK / PASTE
-- =========================================================
nmap("<leader>y", '"+y', "Yank: Clipboard")
vmap("<leader>y", '"+y', "Yank: Clipboard")
nmap("<leader>Y", '"+Y', "Yank: Line to Clipboard")
nmap("<leader>p", '"+p', "Paste: Clipboard")
vmap("<leader>p", '"+p', "Paste: Clipboard")
nmap("<leader>P", '"+P', "Paste: Clipboard Before")

nmap("<leader>ya", function()
  vim.cmd('normal! ggVG"+y')
end, "Yank: All")

vmap("p", '"_dP', "Paste Over Selection")

-- =========================================================
-- COMENTARIOS (Limpio para mini.comment)
-- =========================================================
nmap("<leader>/", "gcc", "Comment: Toggle Line")
vmap("<leader>/", "gc", "Comment: Toggle Selection")

-- =========================================================
-- EDICIÓN RÁPIDA
-- =========================================================
imap("<C-c>", "<Esc>", "Insert: Escape")
nmap("<C-c>", "<cmd>nohlsearch<CR>", "Clear Search Highlight")

vmap("<", "<gv", "Unindent and Keep Selection")
vmap(">", ">gv", "Indent and Keep Selection")

-- Centrar pantalla en scrolls y búsquedas
nmap("<C-d>", "<C-d>zz", "Scroll Down and Center")
nmap("<C-u>", "<C-u>zz", "Scroll Up and Center")

nmap("n", "nzzzv", "Next Search Result Centered")
nmap("N", "Nzzzv", "Previous Search Result Centered")

nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace Word Globally")

nmap("<leader>X", "<cmd>!chmod +x %<CR>", "Make File Executable")
nmap("<leader>re", "<cmd>restart<CR>", "Restart Config")

-- Mapeo libre para plegados (Folds)
nmap("<leader>z", "za", "Fold: Toggle under cursor")

-- =========================================================
-- DUPLICAR LÍNEA / BLOQUE
-- =========================================================
nmap("<leader>dd", "yyp", "Duplicate: Line Below")
vmap("<leader>dd", "y'>p", "Duplicate: Selection")

-- =========================================================
-- UNDOTREE Y GESTIÓN DE BUFFER
-- =========================================================
nmap("<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, "Toggle Builtin Undotree")

-- Input interactivo para renombrar o poner nombre al buffer actual
nmap("<leader>br", function()
  vim.ui.input({ prompt = "Nuevo nombre del Buffer: " }, function(input)
    if input and input ~= "" then vim.cmd("file " .. input) end
  end)
end, "Buffer: Rename / Set Name")

-- =========================================================
-- GESTIÓN Y DIVISIÓN DE VENTANAS (SPLITS)
-- =========================================================
nmap("<leader>v", "<cmd>vsplit<CR>", "Window: Split Vertical")
nmap("<leader>h", "<cmd>split<CR>", "Window: Split Horizontal")

-- Navegar entre paneles usando Ctrl + dirección de movimiento de Vim
nmap("<C-h>", "<C-w>h", "Window: Focus Left")
nmap("<C-j>", "<C-w>j", "Window: Focus Down")
nmap("<C-k>", "<C-w>k", "Window: Focus Up")
nmap("<C-l>", "<C-w>l", "Window: Focus Right")

-- Redimensionar ventanas usando Alt + flechas de dirección en Modo Normal
nmap("<M-Up>", "<cmd>resize +2<CR>", "Window: Resize Up")
nmap("<M-Down>", "<cmd>resize -2<CR>", "Window: Resize Down")
nmap("<M-Left>", "<cmd>vertical resize -2<CR>", "Window: Resize Left")
nmap("<M-Right>", "<cmd>vertical resize +2<CR>", "Window: Resize Right")

-- Buscar visualmente el texto seleccionado en todo el proyecto usando Snacks Grep
vmap("<leader>fg", function()
  local old_reg = vim.fn.getreg("v")
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", old_reg)
  require("snacks").picker.grep({ search = text })
end, "Find: Grep Visual Selection")