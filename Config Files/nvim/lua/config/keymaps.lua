local map = vim.keymap.set

-- Árbol y Buscador
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "Explorer: Toggle" })

map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find: files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Find: grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find: buffers" })

-- Git
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git: status (Fugitive)" })
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Git: Lazygit (Snacks)" })
map("n", "<leader>gl", function() Snacks.lazygit.log() end, { desc = "Git: Log (Snacks)" })

-- Básicos
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })

-- Config
map("n", "<leader>ve", "<cmd>edit $MYVIMRC<CR>", { desc = "Vim: edit init.lua" })

-- LSP (Centralizado)
map("n", "K",          vim.lsp.buf.hover,           { desc = "LSP: hover" })
map("n", "gd",         vim.lsp.buf.definition,      { desc = "LSP: definición" })
map("n", "gr",         vim.lsp.buf.references,      { desc = "LSP: referencias" })
map("n", "<leader>lr", vim.lsp.buf.rename,          { desc = "LSP: renombrar" })
map("n", "<leader>la", vim.lsp.buf.code_action,     { desc = "LSP: acciones de código" })
map("n", "<leader>ld", vim.diagnostic.open_float,   { desc = "LSP: ver error flotante" })

-- Formateo (Usando Conform)
map("n", "<leader>lf", function() 
    require("conform").format({ async = true, lsp_fallback = true }) 
end, { desc = "LSP: formatear" })

-- GitHub Copilot
map("i", "<C-j>", function()
    if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
    else
        return "<C-j>"
    end
end, { expr = true, silent = true, desc = "Copilot: Accept" })

map("n", "<leader>co", "<cmd>Copilot panel<CR>", { desc = "Copilot: Open Panel" })
map("n", "<leader>ct", "<cmd>Copilot toggle<CR>", { desc = "Copilot: Toggle On/Off" })

-- Snacks Terminal: Abre una terminal flotante
-- Toggle de la terminal flotante
map("n", "<leader>tt", function() Snacks.terminal() end, { desc = "Terminal: Toggle Float" })

-- Tip pro: Si quieres abrir la terminal dentro de un buffer ya abierto sin cerrar el anterior:
map("t", "<esc><esc>", "<cmd>close<cr>", { desc = "Terminal: Cerrar con Esc-Esc" })

-- Snacks Toggle: Atajos útiles para activar/desactivar cosas rápidamente
map("n", "<leader>td", function() Snacks.toggle.diagnostics() end, { desc = "Toggle Diagnostics" })
map("n", "<leader>tl", function() Snacks.toggle.line_number() end, { desc = "Toggle Line Numbers" })
map("n", "<leader>tz", function() Snacks.zen() end, { desc = "Toggle Zen Mode" })

-- En tu archivo keymaps.lua
map("n", "<leader>cp", "<cmd>CccPick<CR>", { desc = "Color: Pick/Edit" })
map("n", "<leader>ch", "<cmd>CccHighlighterToggle<CR>", { desc = "Color: Toggle Highlighter" })