-- =========================================================
-- lualine.lua
-- Toma los colores directamente desde theme.lua
-- =========================================================

local theme = require("theme").colors

return {
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
      replace = {
        a = { fg = theme.bg0, bg = theme.red2, gui = "bold" },
        b = { fg = theme.fg0, bg = theme.bg3 },
        c = { fg = theme.fg0, bg = theme.bg1 },
      },
      command = {
        a = { fg = theme.bg0, bg = theme.green, gui = "bold" },
        b = { fg = theme.fg0, bg = theme.bg3 },
        c = { fg = theme.fg0, bg = theme.bg1 },
      },
      inactive = {
        a = { fg = theme.border, bg = theme.bg0 },
        b = { fg = theme.border, bg = theme.bg0 },
        c = { fg = theme.border, bg = theme.bg0 },
      },
    },

    globalstatus = true,
    icons_enabled = true,
    component_separators = { left = "│", right = "│" },
    section_separators = { left = "", right = "" },
    always_divide_middle = true,
  },

  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      {
        "filename",
        path = 1,
        symbols = {
          modified = " ●",
          readonly = " ",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
    },
    lualine_x = { "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { "filename", path = 1 },
    },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },

  tabline = {
    lualine_a = {
      {
        "buffers",
        show_filename_only = true,
        max_length = vim.o.columns * 2 / 3,
        symbols = {
          modified = " ●",
          alternate_file = "",
          directory = "",
        },
      },
    },
    lualine_z = { "tabs" },
  },

  winbar = {
    lualine_c = {
      {
        "filename",
        path = 1,
        color = { fg = theme.fg0, bg = theme.bg1, gui = "bold" },
      },
    },
  },

  inactive_winbar = {
    lualine_c = {
      {
        "filename",
        path = 0,
        color = { fg = theme.gray, bg = theme.bg0 },
      },
    },
  },

  extensions = { "nvim-tree" },
}
