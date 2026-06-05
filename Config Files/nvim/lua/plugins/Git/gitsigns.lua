-- =========================================================
-- Gitsigns: Indicadores de Git en el margen (signcolumn).
-- Muestra iconos en el borde izquierdo para saber qué líneas
-- has añadido, modificado o borrado en tiempo real, sin 
-- tener que consultar la terminal o hacer un commit.
-- =========================================================

return {
  "lewis6991/gitsigns.nvim",
  lazy = false, -- Se carga al inicio para ver los cambios desde el primer momento
  config = function()
    require('gitsigns').setup({
      -- Personalización de los iconos en el margen izquierdo
      signs = {
        add          = { text = ' ' }, -- Línea nueva
        change       = { text = ' ' }, -- Línea modificada
        delete       = { text = ' ' }, -- Línea borrada
        topdelete    = { text = ' ' }, -- Borrado al inicio del archivo
        changedelete = { text = ' ' }, -- Cambio + Borrado
        untracked    = { text = ' ' }, -- Archivo no rastreado por Git
      },
      signcolumn = true, -- Activa la columna de signos
      watch_gitdir = {
        interval = 1000,   -- Revisa cambios en el directorio .git cada segundo
        follow_files = true
      },
    })
  end
}