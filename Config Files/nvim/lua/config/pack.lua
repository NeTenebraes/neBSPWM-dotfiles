-- =========================================================
-- pack.lua
-- Instalación y carga centralizada de plugins.
-- =========================================================

local pack_path = vim.fn.stdpath("config") .. "/pack/plugins"

local plugins = {
  -- =========================
  -- Core
  -- =========================
  { url = "https://github.com/nvim-treesitter/nvim-treesitter", dest = "start/nvim-treesitter" },
  { url = "https://github.com/neovim/nvim-lspconfig", dest = "start/nvim-lspconfig" },

  -- =========================
  -- Completion
  -- =========================
  { url = "https://github.com/hrsh7th/nvim-cmp", dest = "start/nvim-cmp" },
  { url = "https://github.com/hrsh7th/cmp-nvim-lsp", dest = "start/cmp-nvim-lsp" },
  { url = "https://github.com/hrsh7th/cmp-buffer", dest = "start/cmp-buffer" },
  { url = "https://github.com/hrsh7th/cmp-path", dest = "start/cmp-path" },

  -- =========================
  -- UI
  -- =========================
  { url = "https://github.com/lewis6991/gitsigns.nvim", dest = "start/gitsigns.nvim" },
  { url = "https://github.com/EdenEast/nightfox.nvim", dest = "start/nightfox.nvim" },
  { url = "https://github.com/folke/snacks.nvim", dest = "start/snacks.nvim" },
  { url = "https://github.com/nvim-tree/nvim-web-devicons", dest = "start/nvim-web-devicons" },

  -- =========================
  -- Editing
  -- =========================
  { url = "https://github.com/windwp/nvim-autopairs", dest = "start/nvim-autopairs" },
  { url = "https://github.com/windwp/nvim-ts-autotag", dest = "start/nvim-ts-autotag" },
  { url = "https://github.com/echasnovski/mini.nvim", dest = "start/mini.nvim" },
  { url = "https://github.com/numToStr/Comment.nvim", dest = "start/Comment.nvim" },

  -- =========================
  -- LSP / Tools
  -- =========================
  { url = "https://github.com/williamboman/mason.nvim", dest = "start/mason.nvim" },
  { url = "https://github.com/mason-org/mason-lspconfig.nvim", dest = "start/mason-lspconfig.nvim" },
  { url = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", dest = "start/mason-tool-installer.nvim" },
  { url = "https://github.com/stevearc/conform.nvim", dest = "start/conform.nvim" },
  { url = "https://github.com/mfussenegger/nvim-lint", dest = "start/nvim-lint" },

  -- =========================
  -- Debug
  -- =========================
  { url = "https://github.com/mfussenegger/nvim-dap", dest = "start/nvim-dap" },
  { url = "https://github.com/rcarriga/nvim-dap-ui", dest = "start/nvim-dap-ui" },
  { url = "https://github.com/nvim-lualine/lualine.nvim", dest = "start/lualine.nvim" },
  { url = "https://github.com/akinsho/bufferline.nvim", dest = "start/bufferline.nvim" },
}

for _, plugin in ipairs(plugins) do
  local path = pack_path .. "/" .. plugin.dest
  if vim.fn.empty(vim.fn.glob(path)) == 1 then
    vim.fn.system({ "git", "clone", "--depth=1", "--filter=blob:none", plugin.url, path })
  end
end

-- Base
pcall(require, "plugins.treesitter")

-- LSP
pcall(require, "plugins.lsp.mason")
pcall(require, "plugins.lsp.lsp")
pcall(require, "plugins.lsp.conform_lint")
pcall(require, "plugins.lsp.dap")
pcall(require, "plugins.lsp.cmp")

-- Editing
pcall(require, "plugins.editor.autopairs")
pcall(require, "plugins.editor.autotag")
pcall(require, "plugins.editor.comment")

pcall(require, "plugins.mini")

-- UI
pcall(require, "plugins.UI.devicons")
pcall(require, "plugins.UI.nightfox")
pcall(require, "plugins.UI.gitsigns")
pcall(require, "plugins.UI.snacks")
pcall(require, "plugins.UI.lualine")
pcall(require, "plugins.UI.bufferline")