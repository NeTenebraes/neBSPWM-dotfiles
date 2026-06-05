-- =========================================================
-- Lualine: Barra de estado (Statusline) personalizada.
-- Configura la estética de la barra inferior, incluyendo
-- colores por modo (Normal, Insertar, etc.) y secciones
-- con información de Git, nombre de archivo y posición.
-- =========================================================

-- Intentamos cargar los colores del archivo theme.lua
local status, theme_mod = pcall(require, "theme")
local theme = status and theme_mod.colors or {}

-- Si no existe el archivo theme.lua, definimos colores de respaldo (Fallback)
if not status then
  theme = {
    bg0 = "#1a1b26", bg1 = "#16161e", bg3 = "#3b4261",
    fg0 = "#c0caf5", red1 = "#f7768e", pink = "#bb9af7",
    orange = "#ff9e64", green = "#73daca", border = "#3b4261"
  }
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = {
          normal = {
            a = { fg = theme.bg0, bg = theme.red1, gui = "bold" },
            b = { fg = theme.fg0, bg = theme.bg3 },
            c = { fg = theme.fg0, bg = theme.bg1 },
          },
          insert = {
            a = { fg = theme.bg0, bg = theme.pink, gui = "bold" },
            b = { fg = theme.fg0, bg = theme.bg3 },
            c = { fg = theme.fg0, bg = theme.bg1 },
          },
          visual = {
            a = { fg = theme.bg0, bg = theme.orange, gui = "bold" },
            b = { fg = theme.fg0, bg = theme.bg3 },
            c = { fg = theme.fg0, bg = theme.bg1 },
          },
          command = {
            a = { fg = theme.bg0, bg = theme.green, gui = "bold" },
            b = { fg = theme.fg0, bg = theme.bg3 },
            c = { fg = theme.fg0, bg = theme.bg1 },
          },
        },
        globalstatus = true,
        icons_enabled = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}