-- =========================================================
-- treesitter.lua
-- Treesitter base para resaltado, indentado y soporte de autotag.
-- =========================================================

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  return
end

ts.install({
  -- Base
  "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",

  -- Shell / sistema
  "bash", "awk", "tmux", "make", "cmake",

  -- Lenguajes principales
  "c", "cpp", "python", "java",

  -- Web
  "html", "css", "javascript", "typescript", "tsx",
  "json", "yaml", "toml", "scss", "dockerfile",
  "graphql", "xml", "svelte", "vue", "astro",

  -- Otros útiles
  "sql", "regex", "diff", "gitignore", "gitcommit",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buftype = vim.bo[args.buf].buftype
    local filetype = vim.bo[args.buf].filetype

    if buftype ~= "" then
      return
    end

    local ignore_ft = {
      "help",
      "qf",
      "checkhealth",
      "snacks_picker_input",
      "snacks_picker_list",
    }

    if vim.tbl_contains(ignore_ft, filetype) then
      return
    end

    local success, parser = pcall(vim.treesitter.get_parser, args.buf)
    if success and parser then
      vim.treesitter.start(args.buf)
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel = 99