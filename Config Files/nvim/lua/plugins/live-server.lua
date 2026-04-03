return {
  "ngtuonghy/live-server-nvim",
  event = "VeryLazy",
  build = ":LiveServerInstall",
  config = function()
    require("live-server-nvim").setup({
      custom = {
        "--port=9091",
        -- "--no-css-inject", -- Descomenta si prefieres que NO inyecte CSS automáticamente
      },
      serverPath = vim.fn.stdpath("data") .. "/live-server/",
      open = "folder", -- "folder" busca el index.html en la raíz, "cwd" usa la carpeta actual
    })

    -- Atajos de teclado integrados
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    keymap("n", "<leader>ls", ":LiveServerStart<CR>", { desc = "Iniciar Live Server" })
    keymap("n", "<leader>lS", ":LiveServerStop<CR>", { desc = "Detener Live Server" })
    keymap("n", "<leader>lt", function() 
      require("live-server-nvim").toggle() 
    end, { desc = "Toggle Live Server" })
  end,
}
