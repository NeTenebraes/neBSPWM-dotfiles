-- lua/plugins/lsp/dap.lua
local ok_dap, dap = pcall(require, "dap")
if not ok_dap then
  return
end

local ok_dapui, dapui = pcall(require, "dapui")
if not ok_dapui then
  return
end

local ok_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")
if not ok_mason_dap then
  return
end

mason_dap.setup({
  ensure_installed = {
    "js-debug-adapter",
    "python",
    "bash-debug-adapter",
    "codelldb",
  },
  automatic_installation = true,
})

local mason_path = vim.fn.stdpath("data") .. "/mason"
local js_debug_path = mason_path .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
local bashdb_dir = mason_path .. "/packages/bash-debug-adapter/extension/bashdbDir"
local bashdb_path = bashdb_dir .. "/bashdb"
local codelldb_adapter = mason_path .. "/packages/codelldb/extension/adapter/codelldb"

-- ===============================
-- Terminal externa para programas interactivos
-- ===============================
dap.defaults.fallback.focus_terminal = true

-- KITTY
dap.defaults.fallback.external_terminal = {
  command = "/usr/bin/kitty",
  args = { "--hold", "-e" },
}

-- Si usas otra terminal, cambia SOLO este bloque:
-- ALACRITTY
-- dap.defaults.fallback.external_terminal = {
--   command = "/usr/bin/alacritty",
--   args = { "-e" },
-- }

-- WEZTERM
-- dap.defaults.fallback.external_terminal = {
--   command = "/usr/bin/wezterm",
--   args = { "start", "--always-new-process", "--" },
-- }

-- GNOME TERMINAL
-- dap.defaults.fallback.external_terminal = {
--   command = "/usr/bin/gnome-terminal",
--   args = { "--" },
-- }

-- ===============================
-- UI
-- ===============================
vim.fn.sign_define("DapBreakpoint", {
  text = "",
  texthl = "DapBreakpoint",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "",
  texthl = "DapBreakpointCondition",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "",
  texthl = "DapBreakpointRejected",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapLogPoint", {
  text = "",
  texthl = "DapLogPoint",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "",
  texthl = "DapStopped",
  linehl = "Visual",
  numhl = "DiagnosticWarn",
})

dapui.setup({
  icons = {
    expanded = "",
    collapsed = "",
    current_frame = "",
  },
  controls = {
    enabled = true,
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "↻",
      terminate = "□",
      disconnect = "",
    },
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.60 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.20 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        { id = "watches", size = 1.0 },
      },
      size = 10,
      position = "bottom",
    },
  },
})

-- No abrir/cerrar automáticamente; control manual con <leader>ui
dap.listeners.before.launch["dapui_config"] = function() end
dap.listeners.before.attach["dapui_config"] = function() end
dap.listeners.before.event_terminated["dapui_config"] = function() end
dap.listeners.before.event_exited["dapui_config"] = function() end

-- ===============================
-- JS / TS
-- ===============================
dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = 8124,
  executable = {
    command = "node",
    args = {
      js_debug_path,
      "8124",
      "127.0.0.1",
    },
  },
  options = {
    detached = false,
  },
}

local node_configs = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch current file (Node External Terminal)",
    program = "${file}",
    cwd = "${workspaceFolder}",
    console = "externalTerminal",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**" },
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to process",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**" },
  },
}

dap.configurations.javascript = node_configs
dap.configurations.typescript = node_configs
dap.configurations.javascriptreact = node_configs
dap.configurations.typescriptreact = node_configs

-- ===============================
-- Python
-- ===============================
dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch current file",
    program = "${file}",
    console = "integratedTerminal",
    pythonPath = function()
      return "python3"
    end,
  },
}

-- ===============================
-- Bash
-- ===============================
dap.adapters.bash = {
  type = "executable",
  command = "node",
  args = {
    mason_path .. "/packages/bash-debug-adapter/bash-debug-adapter",
  },
}

dap.configurations.sh = {
  {
    type = "bash",
    request = "launch",
    name = "Launch bash script",
    program = "${file}",
    cwd = "${workspaceFolder}",
    pathBash = "/bin/bash",
    pathBashdb = bashdb_path,
    pathBashdbLib = bashdb_dir,
    terminalKind = "integrated",
  },
}

-- ===============================
-- C / C++
-- ===============================
dap.adapters.codelldb = {
  type = "executable",
  command = codelldb_adapter,
  name = "codelldb",
}

dap.configurations.c = {
  {
    name = "Launch executable",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

dap.configurations.cpp = dap.configurations.c