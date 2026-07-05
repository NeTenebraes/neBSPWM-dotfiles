local ok, comment = pcall(require, "Comment")
if not ok then
  return
end

comment.setup({
  padding = true,
  sticky = true,
  ignore = "^$",
})