return {
  "windwp/nvim-ts-autotag",
  event = "VeryLazy", -- Carga el plugin solo cuando es necesario para mantener la velocidad
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        -- Habilita el cierre automático de etiquetas
        enable_close = true,
        -- Habilita el renombrado automático de etiquetas
        enable_rename = true,
        -- Habilita el cierre al escribir el slash (ej: </div> al escribir /)
        enable_close_on_slash = false,
      },
    })
  end,
}