-- =========================================================
-- lua/plugins/UI/snacks.lua
-- =========================================================

local status, snacks = pcall(require, "snacks")
if not status then return end

snacks.setup({
  -- Módulos habilitados
  indent = { enabled = true },
  -- Scroll Suave Animado
  scroll = { enabled = true },
  words = { enabled = true },
  input = { enabled = true },
  scope = { enabled = true },
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  toggle = { enabled = true },
  zen = { enabled = true },
  scratch = { enabled = true }, -- ✨ Bloc de notas habilitado

  -- Sistema de Notificaciones Elegante
  notifier = {
    enabled = true,
    timeout = 3000,
    style = "compact",
  },

  -- Configuración del Dashboard
  dashboard = {
    enabled = true,
    sections = {
      { section = "header", padding = 1 },
      { section = "keys", gap = 1, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
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
⣿⣿⢣⠠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣽⣿⣿⣷⣶⣿⣿⠀⠀
⣿⢏⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀]],
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
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
      keys = { ["<esc>"] = "hide" },
      wo = {
        statusline = "", winbar = "", number = false,
        relativenumber = false, signcolumn = "no",
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
        layout = { layout = { position = "left", width = 35 } },
      },
    },
  },
})