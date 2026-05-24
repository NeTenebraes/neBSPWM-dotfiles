-- =========================================================
-- MINI.NVIM: Colección de módulos independientes y ligeros.
-- Reemplaza plugins pesados como lualine y nvim-cmp para
-- mejorar la seguridad y reducir dependencias.
-- =========================================================

return {
  "nvim-mini/mini.nvim",
  version = false, -- Usamos la rama main para Neovim 0.12
  config = function()
    -- 1. AUTOCOMPLETADO (Reemplaza a nvim-cmp)
    -- Implementa un sistema de dos etapas: primero LSP, luego fallback.
    require('mini.completion').setup({
      lsp_completion = {
        source_func = 'completefunc',
        auto_setup = true,
      },
      window = {
        info = { border = 'rounded' },
        signature = { border = 'rounded' },
      },
      -- El fallback por defecto es <C-n> (palabras del buffer).
      fallback_action = '<C-n>', 
    })

    -- 2. BARRA DE ESTADO (Reemplaza a lualine)
    -- Muy ligera y detecta automáticamente si usas mini.icons o gitsigns.
    require('mini.statusline').setup({
      use_icons = true,
      content = {
        -- Puedes dejarlo en nil para usar el look "opinionated" por defecto.
        active = nil, 
      },
    })

    -- 3. TABLINE (Línea de Buffers superior)
    -- Muestra tus buffers abiertos de forma minimalista.
    require('mini.tabline').setup({
      show_icons = true,
      tabpage_section = 'left', -- Útil si usas múltiples pestañas de Vim.
    })

-- 4. AUTOPAIRS (Configuración para C / CS50)
-- 4. AUTOPAIRS (Simplificado al máximo)
    -- Eliminamos < > porque causan conflictos en lógica de C.
    require('mini.pairs').setup({
      modes = { insert = true, command = false, terminal = false },
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
      },
    })

    -- 5. ICONOS (Proveedor centralizado)
    -- Necesario para que los demás módulos de mini muestren iconos.
    require('mini.icons').setup()

    -- 6. EXTRAS RECOMENDADOS (Para tu flujo de seguridad)
    require('mini.surround').setup() -- Para rodear texto (ej: cambiar ' por ").
    require('mini.ai').setup()       -- Mejora los objetos de texto (dentro de funciones, etc).
  
  require('mini.colors').setup({})

  end, 
}