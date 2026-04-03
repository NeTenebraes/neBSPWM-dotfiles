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
        "html", "cssls", "jsonls", "ts_ls",
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

          map("n", "K",          vim.lsp.buf.hover,           "LSP: hover")
          map("n", "gd",         vim.lsp.buf.definition,      "LSP: definición")
          map("n", "gD",         vim.lsp.buf.declaration,     "LSP: declaración")
          map("n", "gi",         vim.lsp.buf.implementation,  "LSP: implementación")
          map("n", "gr",         vim.lsp.buf.references,      "LSP: referencias")
          map("n", "<leader>lr", vim.lsp.buf.rename,          "LSP: renombrar")
          map("n", "<leader>la", vim.lsp.buf.code_action,     "LSP: acciones de código")
          map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "LSP: formatear")
          map("n", "<leader>ld", vim.diagnostic.open_float,   "LSP: ver error flotante")
          map("n", "[d",         vim.diagnostic.goto_prev,    "LSP: error anterior")
          map("n", "]d",         vim.diagnostic.goto_next,    "LSP: error siguiente")
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
      local servers = { "lua_ls", "clangd", "pyright", "bashls", "html", "cssls", "jsonls", "ts_ls" }
      
      for _, server in ipairs(servers) do
        -- Si no tienen config especial arriba, los habilitamos con capabilities básicas
        if not vim.lsp.type_to_id or not vim.lsp.type_to_id[server] then
           vim.lsp.config(server, { capabilities = capabilities })
        end
        vim.lsp.enable(server)
      end
    end,
  },
}