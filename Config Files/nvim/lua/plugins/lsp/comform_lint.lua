local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },

      python = { "isort", "black" },

      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      vue = { "prettierd", "prettier" },
      svelte = { "prettierd", "prettier" },
      astro = { "prettierd", "prettier" },

      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      toml = { "taplo" },

      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      c = { "clang-format" },
      cpp = { "clang-format" },
      java = { "google-java-format" },
    },

    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = true,
    },
  })
end

local ok_lint, lint = pcall(require, "lint")
if ok_lint then
  lint.linters_by_ft = {
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    vue = { "eslint_d" },
    svelte = { "eslint_d" },

    python = { "ruff" },

    sh = { "shellcheck" },
    bash = { "shellcheck" },
    zsh = { "shellcheck" },

    markdown = { "markdownlint" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
    callback = function()
      lint.try_lint()
    end,
  })
end