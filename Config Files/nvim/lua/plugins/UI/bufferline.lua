local ok, bufferline = pcall(require, "bufferline")
if not ok then
  return
end

bufferline.setup({
  options = {
    mode = "buffers",
    separator_style = "thin",
    diagnostics = "nvim_lsp",
    always_show_bufferline = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    color_icons = true,
    offsets = {
      {
        filetype = "snacks_layout_box",
        text = "Explorer",
        text_align = "left",
        separator = true,
      },
    },
  },
})