local map = vim.keymap.set

-- Función auxiliar para declarar atajos de forma limpia y silenciosa
local function nmap(lhs, rhs, desc)
  map("n", lhs, rhs, { silent = true, desc = desc })
end

-- === NAVEGACIÓN, BUSCADOR Y EXPLORADOR ===
nmap("<leader>e",  function() Snacks.explorer() end,     "Explorer: Toggle")            -- [Espacio + e]       -> Activa el File Explorer (Plugin: snacks.nvim)
nmap("<leader>ff", function() Snacks.picker.files() end,  "Find: Files")                 -- [Espacio + f + f]   -> Busca archivos por nombre (Plugin: snacks.nvim)
nmap("<leader>fg", function() Snacks.picker.grep() end,   "Find: Grep")                  -- [Espacio + f + g]   -> Busca texto dentro de archivos (Plugin: snacks.nvim)
nmap("<leader>fb", function() Snacks.picker.buffers() end,"Find: Buffers")               -- [Espacio + f + b]   -> Lista y busca buffers abiertos (Plugin: snacks.nvim)

-- === ACCIONES BÁSICAS Y ENTORNO ===
nmap("<leader>w",  "<cmd>w<CR>",                         "File: Write")                 -- [Espacio + w]       -> Guarda el archivo actual (Nativo de Neovim)
nmap("<leader>q",  "<cmd>q<CR>",                         "Window: Quit")                -- [Espacio + q]       -> Cierra la ventana actual (Nativo de Neovim)
nmap("<leader>ve", "<cmd>edit $MYVIMRC<CR>",             "Vim: Edit init.lua")          -- [Espacio + v + e]   -> Abre tu init.lua para editarlo (Nativo de Neovim)

-- === CONTROL DE GIT (LAZYGIT VIA SNACKS) ===
nmap("<leader>gg", function() Snacks.lazygit() end,      "Git: Lazygit")                -- [Espacio + g + g]   -> Abre la interfaz flotante de Lazygit (Plugin: snacks.nvim)
nmap("<leader>gl", function() Snacks.lazygit.log() end,  "Git: Log History")            -- [Espacio + g + l]   -> Muestra el historial de commits (Plugin: snacks.nvim)

-- === SERVIDOR DE LENGUAJE (LSP) & FORMATEO ===
nmap("K",          vim.lsp.buf.hover,                    "LSP: Hover Docs")             -- [Shift + k]         -> Muestra la documentación del código bajo el cursor (Plugin: nvim-lspconfig)
nmap("gd",         vim.lsp.buf.definition,               "LSP: Go to Definition")       -- [g + d]             -> Salta a la definición de la función/variable (Plugin: nvim-lspconfig)
nmap("gr",         vim.lsp.buf.references,               "LSP: Go to References")       -- [g + r]             -> Lista todas las referencias de lo seleccionado (Plugin: nvim-lspconfig)
nmap("<leader>lr", vim.lsp.buf.rename,                   "LSP: Rename Symbol")          -- [Espacio + l + r]   -> Renombra la variable/función en todo el proyecto (Plugin: nvim-lspconfig)
nmap("<leader>la", vim.lsp.buf.code_action,               "LSP: Code Actions")           -- [Espacio + l + a]   -> Muestra las acciones de código o correcciones del LSP (Plugin: nvim-lspconfig)
nmap("<leader>ld", vim.diagnostic.open_float,             "LSP: Show Line Diagnostic")   -- [Espacio + l + d]   -> Muestra el error/advertencia de la línea en un float (Plugin: nvim-lspconfig)
nmap("<leader>lf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, "LSP: Format File")                                                                -- [Espacio + l + f]   -> Fuerza el formateo estético del archivo (Plugin: conform.nvim)

-- === GITHUB COPILOT ===
map("i", "<C-j>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    return "<C-j>"
  end
end, { expr = true, silent = true, desc = "Copilot: Accept Suggestion" })               -- [Ctrl + j] (Insert) -> Acepta la sugerencia gris de la IA (Plugin: copilot.lua)

nmap("<leader>co", "<cmd>Copilot panel<CR>",             "Copilot: Open Panel")         -- [Espacio + c + o]   -> Abre el panel lateral con múltiples sugerencias (Plugin: copilot.lua)
nmap("<leader>ct", "<cmd>Copilot toggle<CR>",            "Copilot: Toggle")             -- [Espacio + c + t]   -> Activa o desactiva Copilot por completo (Plugin: copilot.lua)
-- Suelo usar máś Gemini, por lo que no he probado muy bien Copilot.
-- Tener en cuenta por futuros bugs


-- === SNACKS TERMINAL & TOGGLES COMPACTOS ===
nmap("<leader>tt", function() Snacks.terminal() end,     "Terminal: Toggle Float")      -- [Espacio + t + t]   -> Abre/esconde la terminal flotante (Plugin: snacks.nvim)
-- Reemplaza tu línea de terminal por esta:
-- Vamos a usar Ctrl + q (C-q) para cerrar la terminal
vim.keymap.set("t", "<C-q>", function()
  Snacks.terminal.toggle()
end, { desc = "Terminal: Close" })  -- [Esc + Esc] (Term)  -> Cierra la terminal flotante desde dentro de ella (Plugin: snacks.nvim)

nmap("<leader>td", function() Snacks.toggle.diagnostics() end, "Toggle: Diagnostics")   -- [Espacio + t + d]   -> Muestra/oculta subrayados de errores de código (Plugin: snacks.nvim)
nmap("<leader>tl", function() Snacks.toggle.line_number() end, "Toggle: Line Numbers")  -- [Espacio + t + l]   -> Muestra/oculta los números de las líneas (Plugin: snacks.nvim)
nmap("<leader>tz", function() Snacks.toggle.zen() end,         "Toggle: Zen Mode")      -- [Espacio + t + z]   -> Activa/desactiva el modo de concentración centrado (Plugin: snacks.nvim)