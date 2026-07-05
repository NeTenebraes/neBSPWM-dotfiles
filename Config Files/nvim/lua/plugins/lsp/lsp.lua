local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok_cmp
  and cmp_lsp.default_capabilities()
  or vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- =========================================================
-- DIAGNÓSTICOS VISUALES
-- =========================================================
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

-- =========================================================
-- DICCIONARIO DE CONFIGURACIONES PERSONALIZADAS
-- =========================================================
local custom_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  emmet_language_server = {
    filetypes = {
      "css",
      "eruby",
      "html",
      "htmldjango",
      "javascript",
      "javascriptreact",
      "typescriptreact",
      "typescript",
      "less",
      "pug",
      "sass",
      "scss",
      "htmlangular",
      "vue",
      "svelte",
      "astro",
    },
  },
  ts_ls = {
    settings = {
      javascript = {
        implicitProjectConfig = { checkJs = false },
      },
      typescript = {
        preserveSymlinks = true,
      },
    },
  },
}

-- =========================================================
-- LISTA DE SERVIDORES A CONFIGURAR Y ACTIVAR
-- =========================================================
local servers = {
  "bashls",
  "clangd",
  "cssls",
  "dockerls",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "pyright",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "yamlls",
  "astro",
  "svelte",
  "vue_ls",
  "prismals",
  "emmet_language_server",
}

for _, server in ipairs(servers) do
  -- Extraemos la config personalizada si existe, o creamos una tabla vacía
  local config = custom_configs[server] or {}
  
  -- Fusionamos de forma segura las capabilities globales con la config específica
  config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})

  -- Aplicamos la configuración completa y activamos el servidor
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end