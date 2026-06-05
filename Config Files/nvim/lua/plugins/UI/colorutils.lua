return {
  "uga-rosa/ccc.nvim",
  event = "VeryLazy",
  config = function()
    local ccc = require("ccc")
    
    ccc.setup({
      -- Habilita el highlighter automático
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
      -- Puedes configurar inputs/outputs aquí si lo deseas. 
      -- Por defecto es excelente.
    })
  end,
}