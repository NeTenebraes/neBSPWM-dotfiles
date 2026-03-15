-- =========================================================
-- lsp.lua
-- LSP nativo para Neovim 0.11+
--
-- Idea:
-- - Mason instala binarios
-- - vim.lsp.config() define ajustes
-- - vim.lsp.enable() activa servidores
-- =========================================================

local M = {}

function M.setup()
  -- Diagnósticos
  vim.diagnostic.config({
    virtual_text = {
      spacing = 2,
      prefix = "●",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "if_many",
    },
  })

  -- Íconos de diagnóstico
  local signs = {
    Error = " ",
    Warn  = " ",
    Info  = " ",
    Hint  = " ",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  -- Keymaps al adjuntar LSP
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "K", vim.lsp.buf.hover, "LSP: hover")
      map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
      map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
      map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
      map("n", "gr", vim.lsp.buf.references, "LSP: references")
      map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: rename")
      map("n", "<leader>la", vim.lsp.buf.code_action, "LSP: code action")
      map("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: format")
      map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: line diagnostics")
      map("n", "[d", vim.diagnostic.goto_prev, "LSP: previous diagnostic")
      map("n", "]d", vim.diagnostic.goto_next, "LSP: next diagnostic")
    end,
  })

  -- Lua
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
        hint = {
          enable = true,
        },
      },
    },
  })

  -- C / C++
  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
    },
  })

  -- Python
  vim.lsp.config("pyright", {
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
    filetypes = { "sh", "bash", "zsh" },
  })

  -- Web / data
  vim.lsp.config("html", {})
  vim.lsp.config("cssls", {})
  vim.lsp.config("jsonls", {})
  vim.lsp.config("ts_ls", {})

  -- Activación explícita
  local servers = {
    "lua_ls",
    "clangd",
    "pyright",
    "bashls",
    "html",
    "cssls",
    "jsonls",
    "ts_ls",
  }

  for _, server in ipairs(servers) do
    vim.lsp.enable(server)
  end
end

return M
