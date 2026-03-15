-- =========================================================
-- lazy.lua
-- Bootstrap de lazy.nvim + plugins.
--
-- Decisiones:
-- - LSP nativo de Neovim 0.11
-- - Mason como instalador de herramientas
-- - Tree-sitter conservador para no romper C
-- - sqls excluido por ahora
-- =========================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Error clonando lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPresiona una tecla para salir..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Tema base
    {
      "dikiaap/minimalist",
      lazy = false,
      priority = 1000,
      config = function()
        local ok = pcall(vim.cmd.colorscheme, "minimalist")
        if not ok then
          vim.cmd.colorscheme("habamax")
        end
        require("theme").setup()
      end,
    },

    -- UI
    { "nvim-tree/nvim-web-devicons", lazy = true },

    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 34,
          side = "left",
        },
        renderer = {
          group_empty = true,
          indent_markers = {
            enable = true,
          },
          icons = {
            git_placement = "before",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
      },
    },

    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = require("config.lualine"),
    },

    -- Telescope
    { "nvim-lua/plenary.nvim", lazy = true },

    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
      opts = {
        defaults = {
          layout_strategy = "vertical",
          sorting_strategy = "ascending",
          layout_config = {
            width = 0.90,
            height = 0.92,
            prompt_position = "top",
          },
          prompt_prefix = "   ",
          selection_caret = " ❯ ",
          path_display = { "truncate" },
        },
      },
    },

    -- Utilidades
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },

    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {},
    },

    {
      "tpope/vim-fugitive",
      cmd = { "Git", "G" },
    },

    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "modern",
        delay = 300,
        notify = true,
      },
      config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        wk.add({
          { "<leader>f", group = "find" },
          { "<leader>g", group = "git" },
          { "<leader>l", group = "lsp" },
          { "<leader>p", group = "plugins" },
          { "<leader>v", group = "vim" },
        })
      end,
    },

    -- Tree-sitter
    {
      "nvim-treesitter/nvim-treesitter",
      event = { "BufReadPost", "BufNewFile" },
      build = ":TSUpdate",
      main = "nvim-treesitter.config",
      opts = {
        ensure_installed = {
          "bash",
          "c",
          "css",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "vim",
          "vimdoc",
        },
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "c" },
        },
        indent = {
          enable = true,
        },
      },
    },

    -- Mason
    {
      "mason-org/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
      build = ":MasonUpdate",
      opts = {
        PATH = "prepend",
        ui = {
          border = "rounded",
        },
      },
    },

    -- Bridge Mason <-> lspconfig
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = {
        "mason-org/mason.nvim",
        "neovim/nvim-lspconfig",
      },
      opts = {
        ensure_installed = {
          "bashls",
          "clangd",
          "cssls",
          "html",
          "jsonls",
          "lua_ls",
          "pyright",
          "ts_ls",
        },
        automatic_enable = false,
      },
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        require("config.lsp").setup()
      end,
    },
  },

  install = {
    colorscheme = { "minimalist", "habamax" },
  },

  checker = {
    enabled = true,
  },

  change_detection = {
    notify = false,
  },
})
