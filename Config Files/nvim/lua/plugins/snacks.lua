local status, snacks = pcall(require, "snacks")
if not status then
  return
end

snacks.setup({
  indent = { enabled = true },
  scroll = { enabled = true },
  words = { enabled = true },
  input = { enabled = true },

  scope = {
    enabled = true,
    cursor = true,
    edge = true,
    min_size = 2,
    max_size = 20,
    treesitter = {
      enabled = true,
      injections = true,
      blocks = {
        enabled = true,
        "function_declaration",
        "function_definition",
        "method_declaration",
        "method_definition",
      },
    },
  },

  dim = {
    enabled = true,
    scope = {
      min_size = 5,
      max_size = 20,
      siblings = true,
    },
    animate = {
      enabled = true,
    },
  },

  bigfile = { enabled = true },
  quickfile = { enabled = true },
  toggle = { enabled = true },
  scratch = { enabled = true },

  notifier = {
    enabled = true,
    timeout = 3000,
    style = "compact",
  },

  image = {
    enabled = true,
  },

  picker = {
    enabled = true,
    sources = {
      explorer = {
        layout = { layout = { position = "left", width = 35 } },
      },
    },
    win = {
      input = {
        keys = {
          ["<c-p>"] = { "toggle_preview", mode = { "n", "i" } },
        },
      },
    },
  },

  zen = {
  enabled = true,
  toggles = {
    -- deja dim apagado si ya lo controlas aparte con tu keymap
    dim = false,
    git_signs = false,
    mini_diff_signs = false,
    diagnostics = false,
    inlay_hints = false,
  },
  show = {
    -- Zen solo apaga barras; no toca layout
    statusline = false,
    tabline = false,
  },
  win = {
    -- NO centra ni cambia tamaño: usa la ventana tal cual
    style = "none",
    backdrop = {
      transparent = false,
      blend = 85,
    },
    wo = {
      -- mantén tu experiencia normal de edición
      number = true,
      relativenumber = false,
      signcolumn = "yes",
      foldcolumn = "0",
    },
  },
},

  dashboard = {
    enabled = true,
    sections = {
      { section = "header", padding = 1 },
      { section = "keys", gap = 1, padding = 1 },
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

  terminal = {
    enabled = true,
    win = {
      style = "float",
      border = "rounded",
      keys = { ["<esc>"] = "hide" },
      wo = {
        statusline = "",
        winbar = "",
        number = false,
        relativenumber = false,
        signcolumn = "no",
      },
    },
  },

  statuscolumn = {
    enabled = true,
    left = { "mark", "sign" },
    right = { "fold", "git" },
  },

  lazygit = {
    enabled = true,
    config = {
      ui = {
        border = "rounded",
      },
    },
    win = {
      position = "float",
      backdrop = 60,
    },
  },

  explorer = {
    enabled = true,
    replace_netrw = true,
    git_status = true,
    trash = true,
  },
})