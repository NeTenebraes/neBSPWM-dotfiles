-- =========================================================
-- lua/plugins/UI/gitsigns.lua
-- =========================================================

local status, gitsigns = pcall(require, "gitsigns")
if not status then return end

gitsigns.setup({
  signs = {
    add          = { text = ' ' },
    change       = { text = ' ' },
    delete       = { text = ' ' },
    topdelete    = { text = ' ' },
    changedelete = { text = ' ' },
    untracked    = { text = ' ' },
  },
  signcolumn = true,
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
})