-- =========================================================
-- nvim-cmp: Motor de autocompletado inteligente.
-- Proporciona el menú desplegable con sugerencias de código,
-- rutas de archivos y palabras del buffer actual.
-- =========================================================

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Se carga solo al empezar a escribir (ahorra memoria)
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- Sugerencias del servidor de lenguaje (LSP)
    "hrsh7th/cmp-buffer",   -- Sugerencias de palabras en el archivo actual
    "hrsh7th/cmp-path",     -- Sugerencias de rutas de carpetas/archivos
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      window = {
        -- Ventanas con bordes redondeados para un look moderno
        completion = cmp.config.window.bordered({ max_height = 5 }),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(), -- Forzar aparición del menú
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter para confirmar
        ['<Tab>'] = cmp.mapping.select_next_item(),        -- Bajar en la lista
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),      -- Subir en la lista
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- Prioridad 1: Inteligencia del lenguaje
        { name = 'path' },     -- Prioridad 2: Rutas del sistema
        { name = 'buffer' },   -- Prioridad 3: Texto del archivo
      })
    })
  end,
}