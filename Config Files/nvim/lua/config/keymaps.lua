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
-- NAVEGACIÓN Y BUSCADORES (Snacks)
-- =========================================================
nmap("<leader>e", function() Snacks.explorer() end, "Explorer: Toggle")
nmap("<leader>ff", function() Snacks.picker.files() end, "Find: Files")
nmap("<leader>fg", function() Snacks.picker.grep() end, "Find: Grep")
nmap("<leader>fb", function() Snacks.picker.buffers() end, "Find: Buffers")

-- Buscar visualmente el texto seleccionado en todo el proyecto
vmap("<leader>fg", function()
  local old_reg = vim.fn.getreg("v")
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", old_reg)
  Snacks.picker.grep({ search = text })
end, "Find: Grep Visual Selection")

-- =========================================================
-- GESTIÓN DE BUFFERS / ARCHIVOS
-- =========================================================
nmap("<leader>w", "<cmd>w<CR>", "File: Write")
nmap("<leader>q", "<cmd>q<CR>", "Window: Quit")
nmap("<leader>ve", "<cmd>edit $MYVIMRC<CR>", "Vim: Edit init.lua")

nmap("<leader>bn", "<cmd>bnext<CR>", "Buffer: Next")
nmap("<leader>bp", "<cmd>bprevious<CR>", "Buffer: Previous")
nmap("<Tab>", "<cmd>bnext<CR>", "Buffer: Next")
nmap("<S-Tab>", "<cmd>bprevious<CR>", "Buffer: Previous")

-- Borrado seguro (mini.bufremove)
nmap("<leader>bd", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then bufremove.delete(0, false) else vim.cmd("bdelete") end
end, "Buffer: Delete Safely")

-- Input interactivo para renombrar el buffer actual
nmap("<leader>br", function()
  vim.ui.input({ prompt = "Nuevo nombre del Buffer: " }, function(input)
    if input and input ~= "" then vim.cmd("file " .. input) end
  end)
end, "Buffer: Rename / Set Name")

-- ✨ Scratchpad flotante (Bloc de notas temporal de Snacks)
nmap("<leader>bs", function() Snacks.scratch() end, "Buffer: Scratchpad Temporal")

-- =========================================================
-- SISTEMA DE NOTIFICACIONES (Snacks Notifier)
-- =========================================================
nmap("<leader>un", function() Snacks.notifier.show_history() end, "Notification: History")
nmap("<leader>uc", function() Snacks.notifier.hide() end, "Notification: Clear All")

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

nmap("<leader>ya", function() vim.cmd('normal! ggVG"+y') end, "Yank: All")
vmap("p", '"_dP', "Paste Over Selection")

-- =========================================================
-- COMENTARIOS (Mapeados hacia mini.comment)
-- =========================================================

nmap("<leader>/", function() 
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gcc", true, false, true), "m", true)
end, "Comment: Toggle Line")

vmap("<leader>/", function() 
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gc", true, false, true), "m", true)
end, "Comment: Toggle Selection")
-- =========================================================
-- EDICIÓN RÁPIDA Y ENVOLTURAS (mini.surround / alineación)
-- =========================================================
-- Nota: 'mini.align' usa automáticamente 'ga' en Modo Visual (No requiere mapeo manual)

imap("<C-c>", "<Esc>", "Insert: Escape")
nmap("<C-c>", "<cmd>nohlsearch<CR>", "Clear Search Highlight")

vmap("<", "<gv", "Unindent and Keep Selection")
vmap(">", ">gv", "Indent and Keep Selection")

-- Pon esto en la sección de Edición Ágil / Scroll
nmap("<C-f>", "<C-f>", "Scroll: Page Down")
nmap("<C-b>", "<C-b>", "Scroll: Page Up")
nmap("n", "nzzzv", "Next Search Result Centered")
nmap("N", "Nzzzv", "Previous Search Result Centered")

nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace Word Globally")
nmap("<leader>X", "<cmd>!chmod +x %<CR>", "Make File Executable")
nmap("<leader>re", "<cmd>restart<CR>", "Restart Config")
nmap("<leader>z", "za", "Fold: Toggle under cursor")

-- Duplicar líneas
nmap("<leader>dd", "yyp", "Duplicate: Line Below")
vmap("<leader>dd", "y'>p", "Duplicate: Selection")

-- =========================================================
-- GESTIÓN Y DIVISIÓN DE VENTANAS (SPLITS)
-- =========================================================
nmap("<leader>v", "<cmd>vsplit<CR>", "Window: Split Vertical")
nmap("<leader>h", "<cmd>split<CR>", "Window: Split Horizontal")

nmap("<C-h>", "<C-w>h", "Window: Focus Left")
nmap("<C-j>", "<C-w>j", "Window: Focus Down")
nmap("<C-k>", "<C-w>k", "Window: Focus Up")
nmap("<C-l>", "<C-w>l", "Window: Focus Right")

nmap("<M-Up>", "<cmd>resize +2<CR>", "Window: Resize Up")
nmap("<M-Down>", "<cmd>resize -2<CR>", "Window: Resize Down")
nmap("<M-Left>", "<cmd>vertical resize -2<CR>", "Window: Resize Left")
nmap("<M-Right>", "<cmd>vertical resize +2<CR>", "Window: Resize Right")

-- =========================================================
-- HERRAMIENTAS ADICIONALES
-- =========================================================
nmap("<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, "Toggle Builtin Undotree")


local keymap = vim.keymap.set

-- =========================================================
-- DEBUGGING (nvim-dap / dap-ui)
-- =========================================================
local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")

if ok_dap then
  nmap("<leader>db", function() dap.toggle_breakpoint() end, "DAP: Toggle Breakpoint")
  nmap("<leader>dc", function() dap.continue() end, "DAP: Start/Continue Session")
  nmap("<leader>dx", function() dap.terminate() end, "DAP: Terminate Session")
  nmap("<leader>do", function() dap.step_over() end, "DAP: Step Over")
  nmap("<leader>di", function() dap.step_into() end, "DAP: Step Into")
  nmap("<leader>du", function() dap.step_out() end, "DAP: Step Out")
  nmap("<leader>dr", function() dap.repl.toggle() end, "DAP: Toggle REPL")
end

if ok_dapui then
  nmap("<leader>ui", function() dapui.toggle() end, "DAP: Toggle UI panel")
end

-- =========================================================
-- GIT (Lazygit & Gitsigns)
-- =========================================================
nmap("<leader>gg", function() Snacks.lazygit() end, "Git: Lazygit")
-- Si usas gitsigns, podrías añadir aquí:
nmap("<leader>gb", "<cmd>Gitsigns blame_line<CR>", "Git: Blame Line")


-- =========================================================
-- TERMINAL (Snacks)
-- =========================================================
-- Abrir terminal flotante
nmap("<leader>tt", function() Snacks.terminal() end, "Terminal: Toggle")

-- =========================================================
-- FOCUS / DIM (oscurecer fuera de la función)
-- =========================================================
nmap("<leader>Z", function() Snacks.toggle.dim():toggle() end, "Focus: Toggle Dim")
-- =========================================================
-- LSP: NAVEGACIÓN Y DIAGNÓSTICOS
-- =========================================================
nmap("[d", vim.diagnostic.goto_prev, "LSP: Prev Diagnostic")
nmap("]d", vim.diagnostic.goto_next, "LSP: Next Diagnostic")
nmap("<leader>de", vim.diagnostic.open_float, "LSP: Show Error Float")
nmap("<leader>dl", vim.diagnostic.setloclist, "LSP: Open Loclist")

-- Toggle Zen mode usando el toggle integrado
nmap("<leader>uz", function() Snacks.toggle.zen():toggle() end, "Zen: Toggle Mode")

nmap("<leader>bX", function()
  local ok, Snacks = pcall(require, "snacks")
  if ok and Snacks.dashboard and Snacks.dashboard.open then
    Snacks.dashboard.open()
  end
end, "Dashboard: Back to Dashboard")