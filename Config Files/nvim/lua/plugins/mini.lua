-- =========================================================
-- lua/plugins/mini.lua
-- Configuración unificada de módulos de mini.nvim
-- =========================================================

-- =========================================================
-- mini.move
-- Mueve líneas y selecciones con Alt + h/j/k/l
-- =========================================================
local ok_move, move = pcall(require, "mini.move")
if ok_move then
  move.setup({
    mappings = {
      left = "<M-h>",
      right = "<M-l>",
      down = "<M-j>",
      up = "<M-k>",

      line_left = "<M-h>",
      line_right = "<M-l>",
      line_down = "<M-j>",
      line_up = "<M-k>",
    },
    options = {
      reindent_linewise = true,
    },
  })
end

-- =========================================================
-- mini.surround
-- Agrega, cambia o elimina delimitadores:
-- paréntesis, comillas, llaves, tags, etc.
-- =========================================================
local ok_surround, surround = pcall(require, "mini.surround")
if ok_surround then
  surround.setup({})
end

-- =========================================================
-- mini.ai
-- Textobjects más inteligentes:
-- inside/around paréntesis, comillas, funciones, bloques, etc.
-- =========================================================
local ok_ai, ai = pcall(require, "mini.ai")
if ok_ai then
  ai.setup({})
end

-- =========================================================
-- mini.comment
-- Comentarios rápidos por línea o bloque.
-- Usa gc / gcc / gbc.
-- =========================================================
local ok_comment, comment = pcall(require, "mini.comment")
if ok_comment then
  comment.setup({})
end

-- =========================================================
-- mini.pairs
-- Autocierre de pares:
-- (), {}, [], "", '', ``
-- =========================================================
local ok_pairs, pairs = pcall(require, "mini.pairs")
if ok_pairs then
  pairs.setup({})
end