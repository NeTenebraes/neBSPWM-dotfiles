-- =========================================================
-- Nvim-autopairs: Cierre automático de paréntesis y llaves.
-- Al escribir un símbolo de apertura ( (, [, {, ", ' ), 
-- el plugin inserta automáticamente el de cierre, ahorrando
-- pulsaciones de teclas y evitando errores de sintaxis.
-- =========================================================

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- Se activa solo cuando empiezas a escribir texto
  opts = {}, -- Usa la configuración por defecto (que es excelente)
}