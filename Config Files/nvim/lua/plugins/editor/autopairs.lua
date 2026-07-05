local ok, autopairs = pcall(require, "nvim-autopairs")
if not ok then
  return
end

autopairs.setup({
  check_ts = true,
  disable_filetype = { "TelescopePrompt", "vim" },
  disable_in_macro = true,
  disable_in_visualblock = false,
  enable_check_bracket_line = true,
  ignored_next_char = "[%w%.]",
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
    typescript = { "string", "template_string" },
    java = false,
  },
})

local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
  local ok_cmp_ap, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  if ok_cmp_ap then
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end