-- =========================================================
-- lua/plugins/UI/nightfox.lua
-- =========================================================

local status, nightfox = pcall(require, "nightfox")
if not status then return end

local my_colors = require("theme").colors 

nightfox.setup({
  options = {
    style = "carbonfox",
    terminal_colors = true,
    transparent = false,
    styles = {
      comments = "italic",
      keywords = "bold",
      types = "italic,bold",
    }
  },
  palettes = {
    carbonfox = {
      bg0      = my_colors.bg0,
      bg1      = my_colors.bg1,
      sel0     = my_colors.bg3,
      fg1      = my_colors.fg0,
      red      = my_colors.red1,
      comment  = my_colors.fg2,
      orange   = my_colors.orange,
      pink     = my_colors.rose,
    },
  },
  specs = {
    carbonfox = {
      syntax = { operator = "red" },
    },
  },
})

vim.cmd("colorscheme carbonfox")
require("theme").setup()