local map = vim.keymap.set

vim.g.mapleader = " "

local function nmap(lhs, rhs, desc)
  map("n", lhs, rhs, { silent = true, desc = desc })
end

local function vmap(lhs, rhs, desc)
  map("v", lhs, rhs, { silent = true, desc = desc })
end

local function imap(lhs, rhs, desc)
  map("i", lhs, rhs, { silent = true, desc = desc })
end

-- === NAVEGACIÓN ===
nmap("<leader>e", function() Snacks.explorer() end, "Explorer: Toggle")
nmap("<leader>ff", function() Snacks.picker.files() end, "Find: Files")
nmap("<leader>fg", function() Snacks.picker.grep() end, "Find: Grep")
nmap("<leader>fb", function() Snacks.picker.buffers() end, "Find: Buffers")

-- === BÁSICOS ===
nmap("<leader>w", "<cmd>w<CR>", "File: Write")
nmap("<leader>q", "<cmd>q<CR>", "Window: Quit")
nmap("<leader>ve", "<cmd>edit $MYVIMRC<CR>", "Vim: Edit init.lua")

-- === CLIPBOARD / YANK / PASTE ===
nmap("<leader>y", '"+y', "Yank: Clipboard")
vmap("<leader>y", '"+y', "Yank: Clipboard")
nmap("<leader>Y", '"+Y', "Yank: Line to Clipboard")
nmap("<leader>p", '"+p', "Paste: Clipboard")
vmap("<leader>p", '"+p', "Paste: Clipboard")
nmap("<leader>P", '"+P', "Paste: Clipboard Before")
nmap("<leader>yy", '"+yy', "Yank: Line Clipboard")

nmap("<leader>ya", function()
  vim.cmd('normal! ggVG"+y')
end, "Yank: All")

vmap("p", '"_dP', "Paste Over Selection")

-- === EDICIÓN RÁPIDA ===
imap("<C-c>", "<Esc>", "Insert: Escape")
nmap("<C-c>", "<cmd>nohlsearch<CR>", "Clear Search Highlight")

vmap("J", ":m '>+1<CR>gv=gv", "Move Selection Down")
vmap("K", ":m '<-2<CR>gv=gv", "Move Selection Up")

vmap("<", "<gv", "Unindent and Keep Selection")
vmap(">", ">gv", "Indent and Keep Selection")

nmap("J", "mzJ`z", "Join Lines Without Moving Cursor")

nmap("<C-d>", "<C-d>zz", "Scroll Down and Center")
nmap("<C-u>", "<C-u>zz", "Scroll Up and Center")

nmap("n", "nzzzv", "Next Search Result Centered")
nmap("N", "Nzzzv", "Previous Search Result Centered")

nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace Word Globally")

nmap("<leader>X", "<cmd>!chmod +x %<CR>", "Make File Executable")
nmap("<leader>re", "<cmd>restart<CR>", "Restart Config")

nmap("<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, "Toggle Builtin Undotree")

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
nmap("<leader>bd", "<cmd>bdelete<CR>", "Buffer: Delete")
nmap("<Tab>", "<cmd>bnext<CR>", "Buffer: Next")
nmap("<S-Tab>", "<cmd>bprevious<CR>", "Buffer: Previous")

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

nmap("K", vim.lsp.buf.hover, "LSP: Hover")
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
nmap("<leader>yy", '"+yy', "Yank: Line Clipboard")

nmap("<leader>ya", function()
  vim.cmd('normal! ggVG"+y')
end, "Yank: All")

vmap("p", '"_dP', "Paste Over Selection")

-- =========================================================
-- COMENTARIOS
-- Usa Comment.nvim:
-- gcc  -> comenta línea
-- gc   -> comenta con motion
-- gbc  -> comentario de bloque
-- =========================================================
nmap("<leader>/", "gcc", "Comment: Toggle Line")
vmap("<leader>/", "gc", "Comment: Toggle Selection")

-- =========================================================
-- EDICIÓN RÁPIDA
-- =========================================================
imap("<C-c>", "<Esc>", "Insert: Escape")
nmap("<C-c>", "<cmd>nohlsearch<CR>", "Clear Search Highlight")

vmap("J", ":m '>+1<CR>gv=gv", "Move Selection Down")
vmap("K", ":m '<-2<CR>gv=gv", "Move Selection Up")

vmap("<", "<gv", "Unindent and Keep Selection")
vmap(">", ">gv", "Indent and Keep Selection")

nmap("J", "mzJ`z", "Join Lines Without Moving Cursor")

nmap("<C-d>", "<C-d>zz", "Scroll Down and Center")
nmap("<C-u>", "<C-u>zz", "Scroll Up and Center")

nmap("n", "nzzzv", "Next Search Result Centered")
nmap("N", "Nzzzv", "Previous Search Result Centered")

nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace Word Globally")

nmap("<leader>X", "<cmd>!chmod +x %<CR>", "Make File Executable")
nmap("<leader>re", "<cmd>restart<CR>", "Restart Config")

-- =========================================================
-- DUPLICAR LÍNEA / BLOQUE
-- =========================================================
nmap("<leader>dd", "yyp", "Duplicate: Line Below")
vmap("<leader>dd", "y'>p", "Duplicate: Selection")

-- =========================================================
-- UNDOTREE
-- =========================================================
nmap("<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, "Toggle Builtin Undotree")

-- =========================================================
-- UNDO / REDO
-- Undo = deshacer cambios
-- Redo = rehacer cambios deshechos
--
-- Atajos nativos de Vim/Neovim:
-- u    -> undo
-- Ctrl-r -> redo
--
-- Ejemplo:
-- 1) escribes algo
-- 2) presionas u para deshacer
-- 3) presionas Ctrl-r para rehacer
--
-- Si quieres atajos extra:
-- nmap("<leader>z", "u", "Undo")
-- nmap("<leader>Z", "<C-r>", "Redo")
-- =========================================================