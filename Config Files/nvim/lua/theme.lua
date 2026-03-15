-- =========================================================
-- theme.lua
-- Tema rojo/oscuro coherente con tu wallpaper y terminal.
--
-- Criterio:
-- - UI: negros rojizos
-- - sintaxis: variantes cálidas
-- - colores fríos solo cuando ayudan mucho
-- - LSP/diagnósticos integrados con la misma paleta
-- =========================================================

local M = {}

M.colors = {
  -- Fondos
  bg0    = "#090507",
  bg1    = "#160b10",
  bg2    = "#211118",
  bg3    = "#301721",
  border = "#5e2230",

  -- Texto
  fg0    = "#f4dfd8",
  fg1    = "#dcc7c0",
  fg2    = "#b79a95",
  white  = "#fff6f3",

  -- Paleta principal
  red1   = "#ef4761",
  red2   = "#f06a7f",
  rose   = "#f2a6b3",
  orange = "#e8a15b",
  peach  = "#f2b8a0",
  wine   = "#8a3345",

  -- Rescate / contraste localizado
  yellow = "#f1d67a",
  ice    = "#b8dff2",
}

local hl = vim.api.nvim_set_hl

local function set(group, opts)
  hl(0, group, opts)
end

local function apply_ui(c)
  set("Normal",       { fg = c.fg0, bg = c.bg0 })
  set("NormalNC",     { fg = c.fg1, bg = c.bg0 })
  set("EndOfBuffer",  { fg = c.bg0, bg = c.bg0 })
  set("SignColumn",   { bg = c.bg0 })
  set("LineNr",       { fg = c.border, bg = c.bg0 })
  set("CursorLineNr", { fg = c.white, bg = c.bg0, bold = true })
  set("CursorLine",   { bg = c.bg1 })
  set("VertSplit",    { fg = c.border, bg = c.bg0 })
  set("WinSeparator", { fg = c.border, bg = c.bg0 })

  set("Visual",     { bg = c.bg3 })
  set("Search",     { fg = c.bg0, bg = c.rose, bold = true })
  set("IncSearch",  { fg = c.bg0, bg = c.red1, bold = true })

  set("Comment",    { fg = c.fg2, italic = true })
  set("NonText",    { fg = c.fg2, bg = c.bg0 })
  set("SpecialKey", { fg = c.rose, bg = c.bg3, bold = true })

  set("NormalFloat", { fg = c.fg0, bg = c.bg2 })
  set("FloatBorder", { fg = c.red1, bg = c.bg2 })
  set("Pmenu",       { fg = c.fg0, bg = c.bg2 })
  set("PmenuSel",    { fg = c.bg0, bg = c.red1, bold = true })

  set("WinBar",      { fg = c.fg0, bg = c.bg1, bold = true })
  set("WinBarNC",    { fg = c.fg2, bg = c.bg0 })
  set("TabLine",     { fg = c.fg0, bg = c.bg1 })
  set("TabLineSel",  { fg = c.bg0, bg = c.red1, bold = true })
  set("TabLineFill", { bg = c.bg0 })
end

local function apply_syntax(c)
  set("String",       { fg = c.rose })
  set("Character",    { fg = c.rose })

  set("Identifier",   { fg = c.fg1, italic = true })
  set("Function",     { fg = c.red2, bold = true })

  set("Keyword",      { fg = c.red1, bold = true })
  set("Statement",    { fg = c.red2, bold = true })
  set("Conditional",  { fg = c.red1, bold = true })
  set("Repeat",       { fg = c.red1, bold = true })

  set("Type",         { fg = c.orange, bold = true })
  set("StorageClass", { fg = c.orange, bold = true })
  set("Structure",    { fg = c.orange, bold = true })
  set("Typedef",      { fg = c.orange, bold = true })

  set("Constant",     { fg = c.peach })
  set("Number",       { fg = c.peach })
  set("Boolean",      { fg = c.peach, bold = true })

  set("PreProc",      { fg = c.orange })
  set("Include",      { fg = c.red1, bold = true })

  set("Special",      { fg = c.wine })
  set("SpecialChar",  { fg = c.ice, bold = true })

  -- C clásico
  set("cFormat",      { fg = c.yellow, bold = true })
  set("cSpecial",     { fg = c.ice, bold = true })

  -- Tree-sitter
  set("@variable",         { fg = c.fg1, italic = true })
  set("@variable.member",  { fg = c.fg0 })
  set("@property",         { fg = c.fg0 })

  set("@string",           { fg = c.rose })
  set("@string.escape",    { fg = c.ice, bold = true })

  set("@function",         { fg = c.red2, bold = true })
  set("@function.call",    { fg = c.red2 })

  set("@keyword",          { fg = c.red1, bold = true })

  set("@type",             { fg = c.orange, bold = true })
  set("@type.builtin",     { fg = c.orange, bold = true })

  set("@constant",         { fg = c.peach })
  set("@number",           { fg = c.peach })

  set("@comment",          { fg = c.fg2, italic = true })
end

local function apply_plugins(c)
  set("NvimTreeNormal",            { fg = c.fg0, bg = c.bg0 })
  set("NvimTreeNormalNC",          { fg = c.fg0, bg = c.bg0 })
  set("NvimTreeFolderName",        { fg = c.fg1 })
  set("NvimTreeOpenedFolderName",  { fg = c.red1, bold = true })
  set("NvimTreeRootFolder",        { fg = c.red2, bold = true })
  set("NvimTreeGitDirty",          { fg = c.red1 })
  set("NvimTreeGitNew",            { fg = c.peach })
  set("NvimTreeSpecialFile",       { fg = c.orange, bold = true })

  set("TelescopeNormal",       { fg = c.fg0, bg = c.bg2 })
  set("TelescopeBorder",       { fg = c.red1, bg = c.bg2 })
  set("TelescopePromptNormal", { fg = c.fg0, bg = c.bg3 })
  set("TelescopePromptBorder", { fg = c.red1, bg = c.bg3 })
  set("TelescopePromptTitle",  { fg = c.bg0, bg = c.red1, bold = true })
  set("TelescopeSelection",    { fg = c.white, bg = c.bg3, bold = true })

  set("GitSignsAdd",    { fg = c.peach,  bg = c.bg0 })
  set("GitSignsChange", { fg = c.orange, bg = c.bg0 })
  set("GitSignsDelete", { fg = c.red1,   bg = c.bg0 })
end

local function apply_lsp(c)
  set("DiagnosticError", { fg = c.red1 })
  set("DiagnosticWarn",  { fg = c.orange })
  set("DiagnosticInfo",  { fg = c.peach })
  set("DiagnosticHint",  { fg = c.ice })

  set("DiagnosticSignError", { fg = c.red1, bg = c.bg0 })
  set("DiagnosticSignWarn",  { fg = c.orange, bg = c.bg0 })
  set("DiagnosticSignInfo",  { fg = c.peach, bg = c.bg0 })
  set("DiagnosticSignHint",  { fg = c.ice, bg = c.bg0 })

  set("DiagnosticVirtualTextError", { fg = c.red1, bg = c.bg1 })
  set("DiagnosticVirtualTextWarn",  { fg = c.orange, bg = c.bg1 })
  set("DiagnosticVirtualTextInfo",  { fg = c.peach, bg = c.bg1 })
  set("DiagnosticVirtualTextHint",  { fg = c.ice, bg = c.bg1 })

  set("DiagnosticUnderlineError", { undercurl = true, sp = c.red1 })
  set("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.orange })
  set("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.peach })
  set("DiagnosticUnderlineHint",  { undercurl = true, sp = c.ice })

  set("LspReferenceText",  { bg = c.bg3 })
  set("LspReferenceRead",  { bg = c.bg3 })
  set("LspReferenceWrite", { bg = c.bg3, bold = true })

  set("LspInlayHint", { fg = c.fg2, bg = c.bg1, italic = true })
end

function M.setup()
  local c = M.colors
  apply_ui(c)
  apply_syntax(c)
  apply_plugins(c)
  apply_lsp(c)
end

return M
