-- =========================================================
-- Lazy.nvim: Gestor de plugins (Bootstrap & Setup).
-- Este archivo se encarga de descargar el gestor 'Lazy' si
-- no está instalado y de cargar todos los módulos de plugins
-- organizados por carpetas (UI, Git, Dependencies, etc.).
-- =========================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Auto-instalación de Lazy.nvim si falta (Bootstrap)
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end

-- Añade Lazy al 'runtime path' de Neovim
vim.opt.rtp:prepend(lazypath)

-- Configuración principal de la carga de plugins
require("lazy").setup({
  spec = {
    -- Importa automáticamente todos los archivos .lua de estas carpetas
    { import = "plugins" }, 
    { import = "plugins.UI" },
    { import = "plugins.Git" },
    { import = "plugins.Dependencies" },
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
  -- Temas de respaldo si el principal falla durante la instalación
  install = { colorscheme = { "carbonfox", "habamax" } },
  -- Revisa automáticamente si hay actualizaciones de plugins
  checker = { enabled = true },
  -- No muestra notificaciones molestas cada vez que guardas un archivo de configuración
  change_detection = { notify = false },
})