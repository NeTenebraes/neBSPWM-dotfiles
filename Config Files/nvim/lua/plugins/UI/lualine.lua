local ok, lualine = pcall(require, "lualine")
if not ok then
  return
end

lualine.setup({
  options = {
    theme = "auto",
    globalstatus = true,
    icons_enabled = true,
    component_separators = { left = "│", right = "│" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = {
      {
        "mode",
        separator = { left = "", right = "" },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_b = {
      { "branch", icon = "" },
      { "diff" },
    },
    lualine_c = {
      {
        "filename",
        path = 0,
        symbols = {
          modified = " ●",
          readonly = " ",
          unnamed = "[No Name]",
        },
      },
    },
    lualine_x = {
      { "diagnostics" },
      { "filetype" },
    },
    lualine_y = {
      { "progress" },
    },
    lualine_z = {
      {
        "location",
        separator = { left = "", right = "" },
        padding = { left = 1, right = 1 },
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
})