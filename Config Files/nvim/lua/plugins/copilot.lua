return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      panel = {
        enabled = true,
        layout = {
          position = "bottom",
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        -- Desactivamos los keymaps internos para usar los de keymaps.lua
        keymap = {
          accept = false,
          next = false,
          prev = false,
          dismiss = false,
        },
      },
      filetypes = {
        markdown = true,
        yaml = false,
        help = false,
        ["."] = false,
      },
      copilot_node_command = 'node',
    })
  end,
}