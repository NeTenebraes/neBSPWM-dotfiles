-- =========================================================
-- lua/plugins/mini.lua
-- Configuración unificada de módulos de mini.nvim
-- =========================================================

-- =========================================================
-- mini.move
-- Mueve líneas y selecciones con Shift + J/K
-- =========================================================
local ok_move, move = pcall(require, "mini.move")
if ok_move then
  move.setup({
    mappings = {
      left = "",
      right = "",
      down = "J",
      up = "K",
      line_left = "",
      line_right = "",
      line_down = "J",
      line_up = "K",
    },
    options = {
      reindent_linewise = true,
    },
  })
end

-- =========================================================
-- mini.surround
-- Configuración ultra-rápida de 2 teclas usando la 'S' mayúscula
-- =========================================================
local ok_surround, surround = pcall(require, "mini.surround")
if ok_surround then
  surround.setup({
    mappings = {
      add = 'Sa',            -- Añadir envoltura (ej: Saw")
      delete = 'Sd',         -- Borrar envoltura (ej: Sd")
      replace = 'Sr',        -- Reemplazar envoltura (ej: Sr'")
      
      find = 'Sf',           -- Buscar envoltura adelante
      find_left = 'SF',      -- Buscar envoltura atrás
      highlight = 'Sh',      -- Resaltar envoltura
      update_n_lines = 'Sn', -- Cambiar límite de líneas
    },
  })
end

-- =========================================================
-- mini.ai
-- Textobjects inteligentes (inside/around paréntesis, funciones, etc.)
-- =========================================================
local ok_ai, ai = pcall(require, "mini.ai")
if ok_ai then
  ai.setup({})
end

-- =========================================================
-- mini.comment
-- Comentarios rápidos por línea o bloque con "gc", "gcc", "gbc"
-- =========================================================
local ok_comment, comment = pcall(require, "mini.comment")
if ok_comment then
  comment.setup({})
end

-- =========================================================
-- mini.pairs
-- Autocierre automático de caracteres idénticos
-- =========================================================
local ok_pairs, pairs = pcall(require, "mini.pairs")
if ok_pairs then
  pairs.setup({})
end

-- =========================================================
-- mini.splitjoin
-- Divide o une argumentos, objetos y tags con "gS"
-- =========================================================
local ok_splitjoin, splitjoin = pcall(require, "mini.splitjoin")
if ok_splitjoin then
  splitjoin.setup({})
end

-- =========================================================
-- mini.bufremove
-- Cierra buffers sin romper la disposición de tus ventanas divididas
-- =========================================================
local ok_bufremove, bufremove = pcall(require, "mini.bufremove")
if ok_bufremove then
  bufremove.setup({})
end

-- =========================================================
-- mini.icons
-- Iconos ultra rápidos compatibles nativamente con Snacks.nvim
-- =========================================================
local ok_icons, icons = pcall(require, "mini.icons")
if ok_icons then
  icons.setup({})
  icons.mock_nvim_web_devicons()
end

-- =========================================================
-- mini.align
-- Alineación interactiva de texto (ga en modo Visual)
-- =========================================================
local ok_align, align = pcall(require, "mini.align")
if ok_align then
  align.setup({})
end

-- =========================================================
-- mini.clue
-- Panel flotante de ayuda para tus atajos de teclado
-- =========================================================
local ok_clue, clue = pcall(require, "mini.clue")
if ok_clue then
  clue.setup({
    clues = {
      clue.gen_clues.builtin_resetted(),
      clue.gen_clues.g(),
    },
    triggers = {
      -- Despierta al presionar espacio (Leader) en normal y visual
      { mode = 'n', keys = '<leader>' },
      { mode = 'x', keys = '<leader>' },
      -- Despierta al usar comandos 'g' (como gc, gd, gr)
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      -- Atajos de ventanas Ctrl+W
      { mode = 'n', keys = '<C-w>' },
    },
    window = {
      delay = 300, -- Tiempo de espera en ms para que aparezca la ayuda
      config = { border = 'rounded' },
    },
  })
end