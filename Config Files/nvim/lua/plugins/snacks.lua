return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Módulos habilitados
    lazygit = { enabled = true },
    notifier = { enabled = true },
    indent = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },
    input = { enabled = true },
    scope = { enabled = true },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    toggle = { enabled = true },
    zen = { enabled = true },

    -- Configuración del Dashboard
    dashboard = {
      enabled = true,
      sections = {
        { section = "header", padding = 1 },
        { section = "keys", gap = 1, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = [[
⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⢿⠃⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠘⠀⠀⠀⠀⠀⠰⠿⠄⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠄⡆⠠⠀⠇⠀⠀⠀⡄⠀⠀⢀⠀
⣿⣿⣿⣿⡿⡝⠀⠀⠀⠀⠀⠀⠀⠂⡄⠀⠀⡈⠀⢠⣶⣶⣶⣾⣶⣷⣶⣶⣶⣶⣶⣤⣶⣿⣶⣶⣶⣷⣷⣶⣿⡿⠿⠶⠷⠦⣄⡀⠀
⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠄⡇⢀⠀⡇⠀⢸⠿⠿⠛⠛⠛⠛⠿⢿⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠁⠀⣀⣀⣀⣠⣄⣀⠙⠀
⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠈⠀⡇⠀⣤⣤⣤⣤⣤⣤⣤⣄⣀⠈⢸⣿⣿⣿⣿⣿⣿⣿⣦⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⠀
⣿⣿⣿⡏⠀⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠉⠉⠙⠛⠿⠿⠀
⣿⣿⣿⠑⢘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠇⠀⣦⠀⠐⠪⠭⢍⠛⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⢀⠀⠀⢠⡀⠀⠀⡀⠀
⣿⣿⡿⠀⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⢰⣤⡀⠤⢤⣤⣤⣤⠄⣨⣿⣿⣿⣿⣿⣿⣿⣿⣇⡐⣛⣈⡒⠁⠛⠁⢀⣴⡇⠀
⣿⣿⢣⠠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣽⣿⣿⣷⣶⣿⣿⠀⠀
⣿⢏⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },

    -- Configuración de la Terminal
    terminal = {
      enabled = true,
      win = {
        style = "float",
        border = "rounded",
        keys = {
          ["<esc>"] = "hide", -- Cierra terminal con Ctrl+q
        },
        wo = {
          statusline = "",
          winbar = "",
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
    },

    -- Configuración de la columna de estado
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" }, 
      right = { "fold", "git" },
    },

    -- Explorador de archivos
    explorer = { 
      enabled = true, 
      replace_netrw = true,
      git_status = true,
      trash = true,
    },
  
    -- Picker (Buscador)
    picker = {
      enabled = true,
      sources = {
        explorer = {
          layout = {
            layout = { position = "left", width = 35 },
          },
        },
      },
    },
  },
}
