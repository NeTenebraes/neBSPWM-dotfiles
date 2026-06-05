return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- 1. Habilitar el módulo de Lazygit
lazygit = { enabled = true },
dashboard = {
      enabled = true,
      sections = {
        { section = "header", padding = 1 },
        { section = "keys", gap = 1, padding = 1 },
        { 
          icon = " ", 
          title = "Recent Files", 
          section = "recent_files", 
          indent = 2, 
          padding = 1 
        },
        { 
          icon = " ", 
          title = "Projects", 
          section = "projects", 
          indent = 2, 
          padding = 1 
        },
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
⣿⢏⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    notifier = { enabled = true },
    indent = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },
    input = { enabled = true },
    scope = { enabled = true },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    -- NUEVOS MÓDULOS RECOMENDADOS
terminal = {
  enabled = true,
  win = {
    style = "float",
    border = "rounded",
    -- ... (resto de tus opciones)
    wo = {
      -- ESTAS SON LAS LÍNEAS QUE LIMPIAN EL BUFFER
      statusline = "",      -- ¡Esto elimina la barra de estado inferior!
      winbar = "",          -- Esto elimina la barra superior si la tuvieras
      number = false,       -- Sin números de línea
      relativenumber = false,
      signcolumn = "no",    -- Sin columna de git/errores
    },
  },
},
    toggle = { enabled = true },
    zen = { enabled = true },
    statuscolumn = {
      enabled = true,
      -- Con esto, Snacks pone las marcas de git a la derecha del número de línea
      left = { "mark", "sign" }, 
      right = { "fold", "git" },
    },
    explorer = { 
    enabled = true, 
    replace_netrw = true, -- Reemplaza el explorador viejo de vim
    git_status = true,    -- Activa iconos y colores de Git
    trash = true,         -- Mover a papelera en lugar de borrar permanente
  },
  
  picker = {
    enabled = true,
    sources = {
      explorer = {
        layout = {
          layout = {
            position = "left", -- Lo fija como sidebar a la izquierda
            width = 35,
          },
        },
      },
    },
  },
  },
}