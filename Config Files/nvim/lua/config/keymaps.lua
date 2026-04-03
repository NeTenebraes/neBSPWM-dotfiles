local map = vim.keymap.set

-- Árbol y Buscador (Plugins esenciales)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Tree: toggle" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find: files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Find: grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find: buffers" })

-- Git
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git: status" })

-- Básicos (Los "Life Savers")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })

-- LSP
map("n", "<leader>f", vim.lsp.buf.format, { desc = "LSP: Format" })

-- Config
map("n", "<leader>ve", "<cmd>edit $MYVIMRC<CR>", { desc = "Vim: edit init.lua" })

-- =========================================================
-- GitHub Copilot (Integración)
-- =========================================================

-- Aceptar sugerencia con Ctrl + j (Modo Insertar)
map("i", "<C-j>", function()
    if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
    else
        return "<C-j>"
    end
end, { expr = true, silent = true, desc = "Copilot: Accept" })

-- Abrir panel de sugerencias con <leader>cp (Modo Normal)
map("n", "<leader>cp", "<cmd>Copilot panel<CR>", { desc = "Copilot: Open Panel" })

-- Alternar Copilot (On/Off) con <leader>ct
map("n", "<leader>ct", "<cmd>Copilot toggle<CR>", { desc = "Copilot: Toggle On/Off" })