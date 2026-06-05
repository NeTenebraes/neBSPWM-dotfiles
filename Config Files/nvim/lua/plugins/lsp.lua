return {
  -- =========================================================
  -- 1. MASON: El instalador de binarios
  -- Descarga servidores LSP, Linters y Formatters automáticamente.
  -- =========================================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        },
      },
    },
  },

  -- =========================================================
  -- 2. MASON-LSPCONFIG: El puente
  -- Asegura que los servidores estén instalados y configurados.
  -- =========================================================
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Lista única de servidores para autoinstalar
      ensure_installed = { 
        "lua_ls", "clangd", "pyright", "bashls", 
        "html", "cssls", "jsonls", "ts_ls", "emmet_ls", "astro",
      },
      automatic_installation = true,
    },
  },

  -- =========================================================
  -- 3. NVIM-LSPCONFIG: La configuración lógica
  -- Aquí definimos cómo se comportan los servidores y el editor.
  -- =========================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      -- --- A. CONFIGURACIÓN DE DIAGNÓSTICOS ---
      -- Define cómo se ven los errores y avisos en el código.
      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- --- B. CAPABILITIES ---
      -- Le dice al servidor que tenemos autocompletado (requiere cmp-nvim-lsp).
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- --- C. ATRECHOS DE TECLADO (Keymaps) ---
      -- Se activan solo cuando entras a un archivo que tiene LSP activo.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
        end,
      })

      -- --- D. CONFIGURACIÓN DE SERVIDORES ESPECÍFICOS ---
      
      -- Lua (para Neovim)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      -- C / C++
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
      })

      -- Python
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Bash
      vim.lsp.config("bashls", {
        capabilities = capabilities,
        filetypes = { "sh", "bash", "zsh" },
      })

      -- --- E. ACTIVACIÓN DE SERVIDORES ---
      local servers = { 
  "lua_ls", 
  "clangd", 
  "pyright", 
  "bashls", 
  "html", 
  "cssls", 
  "jsonls", 
  "ts_ls", 
  "astro",
  "emmet_ls",
  "marksman", -- Inteligencia para tu neCyberWiki (Markdown)
  "eslint",   -- El motor de corrección de errores web
  "dockerls", -- Para tus laboratorios de hacking en Docker
  "yamlls"    -- Configuraciones de sistema y web
}
      
      for _, server in ipairs(servers) do
        -- Si no tienen config especial arriba, los habilitamos con capabilities básicas
        if not vim.lsp.type_to_id or not vim.lsp.type_to_id[server] then
           vim.lsp.config(server, { capabilities = capabilities })
        end
        vim.lsp.enable(server)
      end
    end,
  },
-- 1. MASON-TOOL-INSTALLER: Automatiza la instalación de herramientas (Prettier, Stylua, etc.)
{
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
  -- Web & Wiki
  "astro-language-server",
  "typescript-language-server",
  "html-lsp",
  "emmet-language-server",
  "css-lsp",
  "marksman",       -- Para tu neCyberWiki (Markdown)
  "eslint_d",       -- Linter para lógica JS/TS/Astro
  
  -- Hacking & Sistema
  "clangd",         -- C/C++ (Hacking)
  "pyright",        -- Python (Scripts de automatización)
  "bashls",         -- Bash (Automatización)
  
  -- Formateo
  "prettier",
  "stylua",
},
      auto_update = true,
      run_on_start = true,
    },
  },

  -- 2. CONFORM.NVIM: El encargado de formatear usando los binarios de Mason
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          astro = { "prettier" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
        },
        -- Formateo automático al guardar
        --format_on_save = {
          --timeout_ms = 500,
          --lsp_fallback = true, -- Si Prettier falla, intenta con el LSP
        --},
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      -- Configuramos qué linter usar según el tipo de archivo
      lint.linters_by_ft = {
        astro = { "eslint_d" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
      }

      -- Crea un comando automático para que te "corrija" al guardar o salir del modo insertar
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}