-- =========================================================
-- Vim-Fugitive: El cliente de Git definitivo.
-- Permite ejecutar cualquier comando de Git directamente 
-- desde Neovim (:Git add, :Git commit, etc.) y ofrece una
-- interfaz increíble para resolver conflictos y ver diffs.
-- =========================================================

return {
  "tpope/vim-fugitive",
  -- Solo se carga cuando ejecutas un comando que empieza por :Git o :G
  cmd = { "Git", "G" }, 
}