-- =========================================================
-- init.lua
-- Punto de entrada principal.
-- =========================================================

vim.g.mapleader = " " -- Leader principal.
vim.g.maplocalleader = "\\" -- Leader local.

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args ~= "" then
    local plugins = vim.split(opts.args, "%s+", { trimempty = true })
    vim.pack.update(plugins)
  else
    vim.pack.update()
  end
end, { nargs = "*", desc = "Update all plugins or specific ones" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(function()
      pcall(vim.pack.update)
    end)
  end,
})

require("config.options") -- Carga opciones.
require("config.keymaps") -- Carga keymaps.
require("config.pack") -- Carga plugins y módulos.