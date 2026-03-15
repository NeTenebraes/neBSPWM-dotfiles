-- =========================================================
-- keymaps.lua
-- Atajos globales del usuario.
-- Los keymaps de LSP viven en lsp.lua y solo se cargan
-- cuando un servidor se adjunta al buffer.
-- =========================================================

local map = vim.keymap.set

-- Árbol
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Tree: toggle" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Tree: focus" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find: files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find: grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find: buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find: help" })

-- Git
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git: status" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git: commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git: push" })
map("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git: log" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git: blame" })
map("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git: diff vertical" })

-- Básicos
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Write file" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Write file" })

-- Config propia
map("n", "<leader>ve", "<cmd>edit $MYVIMRC<CR>", { desc = "Vim: edit init.lua" })
map("n", "<leader>vr", "<cmd>source $MYVIMRC<CR>", { desc = "Vim: reload init.lua" })

-- Visual: mover bloques
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Mejor navegación en búsquedas
map("n", "n", "nzzzv", { desc = "Next result centered" })
map("n", "N", "Nzzzv", { desc = "Prev result centered" })

-- Lazy
map("n", "<leader>ps", "<cmd>Lazy<CR>", { desc = "Plugins: open Lazy" })
map("n", "<leader>pu", "<cmd>Lazy sync<CR>", { desc = "Plugins: sync" })

-- Mason
map("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Plugins: Mason" })
