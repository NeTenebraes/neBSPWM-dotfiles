return {
  'MeanderingProgrammer/render-markdown.nvim',
  -- Registramos los comandos para que Lazy los reconozca antes de cargar el plugin
  cmd = { "RenderMarkdown", "RenderMarkdownToggle" },
  ft = { 'markdown', 'vimwiki' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
  opts = {
    latex = { enabled = true }, 
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)
    vim.treesitter.language.register('markdown', 'vimwiki')
  end,
}
