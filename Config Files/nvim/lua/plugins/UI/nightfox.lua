return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- 1. Importamos tu paleta personalizada
    local my_colors = require("theme").colors 

    require("nightfox").setup({
      options = {
        style = "carbonfox",
        terminal_colors = true,
        transparent = false, -- Cambia a true si usas transparencia en la terminal 
        styles = {
          comments = "italic", -- [cite: 1]
          keywords = "bold",   -- [cite: 1]
          types = "italic,bold",
        }
      },
      palettes = {
        carbonfox = {
          bg0      = my_colors.bg0,    -- Negro rojizo profundo (#090507)
          bg1      = my_colors.bg1,    -- Fondo secundario
          sel0     = my_colors.bg3,    -- Color de selección
          fg1      = my_colors.fg0,    -- Texto principal
          red      = my_colors.red1,   -- El rojo vibrante de tu wallpaper 
          comment  = my_colors.fg2,    -- Gris suave para comentarios
          orange   = my_colors.orange,
          pink     = my_colors.rose,
        },
      },
      specs = {
        carbonfox = {
          syntax = {
            operator = "red", -- Operadores en rojo para resaltar 
          },
        },
      },
    })

    -- 2. Aplicamos el tema base
    vim.cmd("colorscheme carbonfox")

    require("theme").setup()
  end,
}