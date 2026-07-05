-- =========================================================
-- pack.lua
-- Centralized plugin installation, update, and loading.
-- =========================================================

local pack_path = vim.fn.stdpath("config") .. "/pack/plugins"

local plugins = {
  -- Core
  { url = "https://github.com/nvim-treesitter/nvim-treesitter", dest = "start/nvim-treesitter" },
  { url = "https://github.com/neovim/nvim-lspconfig", dest = "start/nvim-lspconfig" },

  -- Completion
  { url = "https://github.com/hrsh7th/nvim-cmp", dest = "start/nvim-cmp" },
  { url = "https://github.com/hrsh7th/cmp-nvim-lsp", dest = "start/cmp-nvim-lsp" },
  { url = "https://github.com/hrsh7th/cmp-buffer", dest = "start/cmp-buffer" },
  { url = "https://github.com/hrsh7th/cmp-path", dest = "start/cmp-path" },

  -- UI
  { url = "https://github.com/lewis6991/gitsigns.nvim", dest = "start/gitsigns.nvim" },
  { url = "https://github.com/EdenEast/nightfox.nvim", dest = "start/nightfox.nvim" },
  { url = "https://github.com/folke/snacks.nvim", dest = "start/snacks.nvim" },
  { url = "https://github.com/MeanderingProgrammer/render-markdown.nvim", dest = "start/render-markdown.nvim" },

  -- Editing
  { url = "https://github.com/windwp/nvim-ts-autotag", dest = "start/nvim-ts-autotag" },
  { url = "https://github.com/echasnovski/mini.nvim", dest = "start/mini.nvim" },

  -- LSP / Tools
  { url = "https://github.com/williamboman/mason.nvim", dest = "start/mason.nvim" },
  { url = "https://github.com/mason-org/mason-lspconfig.nvim", dest = "start/mason-lspconfig.nvim" },
  { url = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", dest = "start/mason-tool-installer.nvim" },
  { url = "https://github.com/stevearc/conform.nvim", dest = "start/conform.nvim" },
  { url = "https://github.com/mfussenegger/nvim-lint", dest = "start/nvim-lint" },

  -- Debug
  { url = "https://github.com/mfussenegger/nvim-dap", dest = "start/nvim-dap" },
  { url = "https://github.com/rcarriga/nvim-dap-ui", dest = "start/nvim-dap-ui" },
  { url = "https://github.com/nvim-lualine/lualine.nvim", dest = "start/lualine.nvim" },
  { url = "https://github.com/akinsho/bufferline.nvim", dest = "start/bufferline.nvim" },


  { url = "https://github.com/jay-babu/mason-nvim-dap.nvim", dest = "start/mason-nvim-dap.nvim" },
  { url = "https://github.com/mxsdev/nvim-dap-vscode-js", dest = "start/nvim-dap-vscode-js" },
  -- =========================
  -- Debugging Universales (DAP)
  -- =========================
  { url = "https://github.com/mfussenegger/nvim-dap", dest = "start/nvim-dap" },
  { url = "https://github.com/rcarriga/nvim-dap-ui", dest = "start/nvim-dap-ui" },
  { url = "https://github.com/jay-babu/mason-nvim-dap.nvim", dest = "start/mason-nvim-dap.nvim" },
  { url = "https://github.com/mxsdev/nvim-dap-vscode-js", dest = "start/nvim-dap-vscode-js" },
  { url = "https://github.com/nvim-neotest/nvim-nio", dest = "start/nvim-nio" }, -- REQUISITO OBLIGATORIO PARA DAP-UI
}

-- [BOOTSTRAP ONLY] Clones missing plugins on startup (Fast because it only runs if empty)
for _, plugin in ipairs(plugins) do
  local path = pack_path .. "/" .. plugin.dest
  if vim.fn.empty(vim.fn.glob(path)) == 1 then
    vim.fn.system({ "git", "clone", "--depth=1", "--filter=blob:none", plugin.url, path })
  end
end

-- =========================================================
-- MODULE EXPORTS (For init.lua commands)
-- =========================================================
local M = {}

M.update = function()
  local updated_plugins = {}
  local installed_plugins = {}
  local total_plugins = #plugins
  local completed = 0

  -- Función interna para reportar cuando TODOS los hilos terminen
  local function check_completion()
    completed = completed + 1
    if completed == total_plugins then
      vim.schedule(function()
        if #installed_plugins > 0 then
          vim.notify("🚀 Installed: " .. table.concat(installed_plugins, ", "), vim.log.levels.INFO)
        end

        if #updated_plugins > 0 then
          vim.notify("🔄 Updated: " .. table.concat(updated_plugins, ", "), vim.log.levels.INFO)
        else
          vim.notify("✨ Up to date. No updates found.", vim.log.levels.INFO)
        end
      end)
    end
  end

  -- Lanzamos los procesos en paralelo sin bloquear Neovim
  for _, plugin in ipairs(plugins) do
    local path = pack_path .. "/" .. plugin.dest
    local name = plugin.dest:gsub("start/", "")
    
    if vim.fn.empty(vim.fn.glob(path)) == 1 then
      -- Clonado asíncrono
      vim.system({ "git", "clone", "--depth=1", "--filter=blob:none", plugin.url, path }, {}, function(obj)
        if obj.code == 0 then table.insert(installed_plugins, name) end
        check_completion()
      end)
    else
      -- Pull asíncrono
      vim.system({ "git", "-C", path, "pull", "--ff-only", "--rebase=false" }, {}, function(obj)
        if obj.code == 0 and obj.stdout then
          if not obj.stdout:find("Already up to date") and not obj.stdout:find("Ya está al día") then
            table.insert(updated_plugins, name)
          end
        end
        check_completion()
      end)
    end
  end
end

-- =========================================================
-- MODULE INITIALIZATION
-- =========================================================
pcall(require, "plugins.treesitter")

pcall(require, "plugins.lsp.mason")
pcall(require, "plugins.lsp.lsp")
pcall(require, "plugins.lsp.conform_lint")
pcall(require, "plugins.lsp.dap")
pcall(require, "plugins.lsp.cmp")

pcall(require, "plugins.editor.autopairs")
pcall(require, "plugins.editor.autotag")
pcall(require, "plugins.editor.comment")

pcall(require, "plugins.mini")
pcall(require, "plugins.snacks")

pcall(require, "plugins.UI.nightfox")
pcall(require, "plugins.UI.gitsigns")
pcall(require, "plugins.UI.lualine")
pcall(require, "plugins.UI.bufferline")
pcall(require, "plugins.UI.render-markdown")

return M