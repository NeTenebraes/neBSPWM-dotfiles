vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
  return
end

local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
local ok_mti, mason_tool_installer = pcall(require, "mason-tool-installer")

mason.setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

if ok_mlsp then
  mason_lspconfig.setup({
    ensure_installed = {
      "astro",
      "bashls",
      "clangd",
      "cssls",
      "dockerls",
      "emmet_language_server",
      "html",
      "jsonls",
      "lua_ls",
      "marksman",
      "pyright",
      "tailwindcss",
      "taplo",
      "ts_ls",
      "yamlls",
      "svelte",
      "vue_ls",
      "prismals",
    },
    automatic_enable = false,
  })
end

if ok_mti then
  mason_tool_installer.setup({
    ensure_installed = {
      "prettier",
      "prettierd",
      "stylua",
      "black",
      "isort",
      "ruff",
      "shfmt",
      "shellcheck",
      "clang-format",
      "markdownlint",
    },
    auto_update = true,
    run_on_start = true,
  })
end