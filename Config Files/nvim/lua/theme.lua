-- =========================================================
-- theme.lua
-- Tema rojo/oscuro para Neovim con extrema visibilidad y contraste.
-- Paleta rediseñada para usar colores vibrantes armonizados con burdeos.
-- Reforzado para que TODO Neovim tenga una concordancia cromática,
-- según la lista "nvim_colors_full.txt".
-- =========================================================

local M = {}

M.colors = {

  purple = "#bd93f9",

  test   = "#00ff2f",

  bg0    = "#090507",
  bg1    = "#160b10",
  bg2    = "#211118",
  bg3    = "#301721",
  border = "#5e2230",
  fg0    = "#f4dfd8",
  fg1    = "#dcc7c0",
  fg2    = "#b79a95",
  white  = "#fff6f3", -- para Strings
  vinotinto = "#7b112c",
  red1   = "#ef4761",  -- para Include, keywords
  red2   = "#f06a7f",  -- para Funciones
  coral  = "#f2a6b3",
  gold   = "#fce094",
  cian   = "#8cf8f7",
  mint   = "#b3f6c0",
  yellow = "#f1d67a",
  blue   = "#b8dff2",
  orange = "#e8a15b",
  peach  = "#f2b8a0",
  wine   = "#8a3345",
  class_fg = "#b8dff2",
  namespace_fg = "#8a3345",
  parameter_fg = "#f2b8a0",
  attribute_fg = "#e8a15b",
  grey   = "#5e2230",
  comment_grey = "#b79a95",
  info_fg = "#e0e2ea", info_bg = "#4f5258",
  warning_fg = "#fce094", error_fg = "#ffc0b9",
  folded_fg = "#9b9ea4", added_fg = "#b3f6c0",
  deleted_fg = "#ffc0b9", changed_fg = "#8cf8f7",
}

local c = M.colors
local hl = vim.api.nvim_set_hl
local function set(group, opts) hl(0, group, opts) end

local function apply_ui()
  set("Normal",       { fg = c.fg0, bg = c.bg0 })
  set("NormalNC",     { fg = c.fg1, bg = c.bg0 })
  set("EndOfBuffer",  { fg = c.bg0, bg = c.bg0 })
  set("SignColumn",   { bg = c.bg0 })
  set("LineNr", { fg = c.grey, bg = c.bg0 })
  set("CursorLineNr", { fg = c.white, bg = c.bg0, bold = true })
  set("CursorLine",   { bg = "#12080d" })
  set("Visual",       { fg = c.white, bg = c.vinotinto })
  set("Search",       { fg = c.bg0, bg = c.coral, bold = true })
  set("IncSearch",    { fg = c.bg0, bg = c.red1, bold = true })
  set("CurSearch",    { fg = c.bg0, bg = c.gold, bold = true })
  set("VertSplit",    { fg = c.border, bg = c.bg0 })
  set("WinSeparator", { fg = c.border, bg = c.bg0 })
  set("ColorColumn",  { bg = c.bg1 })
  set("Comment",    { fg = c.comment_grey, italic = true })
  set("NonText",    { fg = c.fg2, bg = c.bg0 })
  set("SpecialKey", { fg = c.coral, bg = c.bg3, bold = true })
  set("NormalFloat", { fg = c.fg0, bg = c.bg2 })
  set("FloatBorder", { fg = c.red1, bg = c.bg2 })
  set("Pmenu",         { fg = c.fg1, bg = c.bg2 })
  set("PmenuSel",      { fg = c.bg0, bg = c.red1, bold = true })
  set("PmenuMatch",    { fg = c.gold, bold = true })
  set("PmenuMatchSel", { fg = c.yellow, bold = true })
  set("PmenuSbar",     { bg = c.bg2 })
  set("PmenuThumb",    { bg = c.gold })
  set("StatusLine",   { fg = c.info_fg, bg = c.info_bg })
  set("StatusLineNC", { fg = "#c4c6cd", bg = "#2c2e33" })
  set("WinBar",      { fg = c.info_fg, bg = c.bg1, bold = true })
  set("WinBarNC",    { fg = c.comment_grey, bg = c.bg0 })
  set("TabLine",      { fg = c.info_fg, bg = c.bg1 })
  set("TabLineSel",   { fg = c.bg0, bg = c.red1, bold = true })
  set("TabLineFill",  { bg = c.bg0 })
  set("Cursor",       { fg = c.bg0, bg = c.red1 })
  set("TermCursor",   { fg = c.bg0, bg = c.red1 })
  set("Directory",    { fg = c.cian })
  set("Question",     { fg = c.cian })
  set("MoreMsg",      { fg = c.cian })
  set("WarningMsg",   { fg = c.warning_fg, bold = true })
  set("ErrorMsg",     { fg = c.error_fg, bold = true })
  set("Title",        { fg = c.info_fg, bold = true })
end

local function apply_git()
  set("DiffAdd",    { fg = c.fg0, bg = c.mint })
  set("DiffChange", { fg = c.fg0, bg = c.blue })
  set("DiffDelete", { fg = c.fg0,  bg = c.error_fg })
  set("DiffText",   { fg = c.bg0,  bg = c.gold, bold = true })
  set("Added",   { fg = c.mint })
  set("Changed", { fg = c.blue })
  set("Removed", { fg = c.error_fg })
end

local function apply_syntax()
  set("String",       { fg = c.white }) -- solo esto es blanco puro
  set("Character",    { fg = c.white })
  set("Identifier",   { fg = c.cian, italic = true })
  set("Function",     { fg = c.red2, bold = true })
  set("@function.method",  { fg = c.red2, bold = true })
  set("@method",           { fg = c.red2, bold = true })
  set("@constructor",      { fg = c.attribute_fg, bold = true })
  set("Keyword",      { fg = c.red1, bold = true })
  set("Statement",    { fg = c.vinotinto, bold = true })
  set("Conditional",  { fg = c.red1, bold = true })
  set("Repeat",       { fg = c.red1, bold = true })
  set("Type",         { fg = c.gold, bold = true })
  set("@type.builtin",     { fg = c.yellow, bold = true })
  set("@type.definition",  { fg = c.class_fg, bold = true })
  set("@type.class",       { fg = c.class_fg, bold = true })
  set("@type.interface",   { fg = c.class_fg, bold = true })
  set("@type.enum",        { fg = c.class_fg, bold = true })
  set("StorageClass", { fg = c.gold, bold = true })
  set("Structure",    { fg = c.gold, bold = true })
  set("Typedef",      { fg = c.gold, bold = true })
  set("Constant",     { fg = c.gold, bold = true })
  set("Number",       { fg = c.gold })
  set("Float",        { fg = c.peach })
  set("Boolean",      { fg = c.yellow, bold = true })
  set("PreProc",      { fg = c.yellow })
  set("Include",      { fg = c.red1, bold = true }) -- <stdio.h>, etc.
  set("Special",      { fg = c.wine })
  set("SpecialChar",  { fg = c.blue, bold = true })
  set("cFormat",      { fg = c.yellow, bold = true })
  set("cSpecial",     { fg = c.blue, bold = true })

  -- Tree-sitter avanzado
  set("@variable",         { fg = c.cian, italic = true })
  set("@variable.member",  { fg = c.info_fg })
  set("@variable.builtin", { fg = c.yellow, bold = true })
  set("@parameter",        { fg = c.parameter_fg, italic = true })
  set("@field",            { fg = c.property, italic = true })
  set("@property",         { fg = c.gold, italic = true })
  set("@attribute",        { fg = c.attribute_fg, bold = true })
  set("@namespace",        { fg = c.namespace_fg, bold = true })
  set("@module",           { fg = c.namespace_fg, bold = true })
  set("@label",            { fg = c.yellow, bold = true })
  set("@property",         { fg = c.gold, italic = true })
  set("@string",           { fg = c.white }) -- solo esto es blanco puro
  set("@string.escape",    { fg = c.blue, bold = true })
  set("@string.regex",     { fg = c.blue, bold = true })
  set("@string.special",   { fg = c.blue, bold = true })
  set("@function",         { fg = c.red2, bold = true })
  set("@function.call",    { fg = c.gold, bold = true })
  set("@function.builtin", { fg = c.red1, bold = true })
  set("@keyword",          { fg = c.red1, bold = true })
  set("@keyword.function", { fg = c.red1, bold = true })
  set("@keyword.operator", { fg = c.red1 })
  set("@keyword.import",   { fg = c.red1, bold = true })
  set("@keyword.exception",{ fg = c.red1, bold = true })
  set("@keyword.operator", { fg = c.red1 })
  set("@keyword.return",   { fg = c.red1, bold = true })
  set("@type",             { fg = c.gold, bold = true })
  set("@constant",         { fg = c.gold, bold = true })
  set("@constant.builtin", { fg = c.yellow, bold = true })
  set("@number",           { fg = c.gold })
  set("@number.float",     { fg = c.peach })
  set("@boolean",          { fg = c.yellow, bold = true })
  set("@comment",          { fg = c.comment_grey, italic = true })
  set("@punctuation.bracket", { fg = c.gold, bold = true })
  set("@punctuation.delimiter", { fg = c.peach, bold = true })
  set("@punctuation.special", { fg = c.wine, bold = true })
  set("@operator", { fg = c.red1, bold = true })
  set("MatchParen", { fg = c.white, bg = c.vinotinto, bold = true })

  -- HTML/JSX/Astro/CSS
  set("@tag",                  { fg = c.red1, bold = true })
  set("@tag.builtin",          { fg = c.vinotinto, bold = true })
  set("@tag.attribute",        { fg = c.gold, italic = true })
  set("@tag.delimiter",        { fg = c.wine })
  set("@type.tag.css",         { fg = c.red1 })
  set("@type.css",             { fg = c.class_fg, bold = true })
  set("@type.class.css",       { fg = c.class_fg, bold = true })
  set("@type.id.css",          { fg = c.orange, bold = true })
  set("@property.css",         { fg = c.gold, bold = true })
  set("cssClassName",          { fg = c.class_fg, bold = true })
  set("cssClassNameDot",       { fg = c.class_fg, bold = true })
  set("@string.css",           { fg = c.white })
  set("@number.css",           { fg = c.gold })
  set("@label.css",            { fg = c.yellow })
  set("@keyword.css",          { fg = c.red1 })
  set("@keyword.modifier.css", { fg = c.gold })
  set("@keyword.value.css",    { fg = c.gold })
  set("@constant.css",         { fg = c.gold })
  set("@string.plain.css",     { fg = c.white })
  set("@variable.css",         { fg = c.cian })
  set("@variable.parameter.css", { fg = c.gold, bold = true })
  set("cssValueKeyword",       { fg = c.gold })

  -- JS/TS
  set("@constructor.javascript", { fg = c.yellow, bold = true })
  set("@variable.parameter",     { fg = c.gold, italic = true })
  set("@keyword.import",         { fg = c.red1, bold = true })

  -- Bash
  set("@function.macro.bash",  { fg = c.red2 })
  set("@parameter.bash",       { fg = c.cian })
  set("@string.special.bash",  { fg = c.blue })
end

local function apply_lsp()
  set("DiagnosticError", { fg = c.error_fg })
  set("DiagnosticWarn",  { fg = c.warning_fg })
  set("DiagnosticInfo",  { fg = c.cian })
  set("DiagnosticHint",  { fg = c.yellow })
  set("DiagnosticSignError", { fg = c.error_fg, bg = c.bg0 })
  set("DiagnosticSignWarn",  { fg = c.warning_fg, bg = c.bg0 })
  set("DiagnosticSignInfo",  { fg = c.cian, bg = c.bg0 })
  set("DiagnosticSignHint",  { fg = c.yellow, bg = c.bg0 })
  set("DiagnosticVirtualTextError", { fg = c.error_fg, bg = c.bg1 })
  set("DiagnosticVirtualTextWarn",  { fg = c.warning_fg, bg = c.bg1 })
  set("DiagnosticVirtualTextInfo",  { fg = c.cian, bg = c.bg1 })
  set("DiagnosticVirtualTextHint",  { fg = c.yellow, bg = c.bg1 })
  set("DiagnosticUnderlineError", { undercurl = true, sp = c.red1 })
  set("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.gold })
  set("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.cian })
  set("DiagnosticUnderlineHint",  { undercurl = true, sp = c.yellow })
  set("LspInlayHint", { fg = c.fg2, bg = c.bg1, italic = true })
  set("LspReferenceText",  { fg = c.cian, bg = c.bg1, bold = true })
  set("LspReferenceRead",  { fg = c.gold, bg = c.bg1, bold = true })
  set("LspReferenceWrite", { fg = c.warning_fg, bg = c.bg1, bold = true })
end

local function apply_plugins()
  set("SnacksDashboardHeader", { fg = c.red1 })
  set("SnacksDashboardTitle",  { fg = c.red2, bold = true })
  set("SnacksDashboardIcon",   { fg = c.rose })
  set("SnacksDashboardDesc",   { fg = c.fg2 })
  set("SnacksDashboardKey",    { fg = c.orange })
  set("SnacksDashboardFile",   { fg = c.fg1 })
  set("SnacksDashboardDir",    { fg = c.fg2 })
  set("LazyNormal",      { fg = c.fg0, bg = c.bg2 })
  set("LazyButton",      { fg = c.fg1, bg = c.bg3 })
  set("LazyButtonActive",{ fg = c.white, bg = c.wine, bold = true })
  set("LazySpecial",     { fg = c.orange })
  set("LazyH1",          { fg = c.bg0, bg = c.red1, bold = true })
  set("LazyProgressTodo", { fg = c.fg2, bg = c.bg1 })
  set("LazyProgressDone", { fg = c.white, bg = c.wine })
  set("LazyProp",         { fg = c.fg2 })
  set("LazyComment",      { fg = c.fg2, italic = true })
  set("MiniStatuslineModeNormal",  { fg = c.bg0, bg = c.red1, bold = true })
  set("MiniStatuslineModeInsert",  { fg = c.bg0, bg = c.orange, bold = true })
  set("MiniStatuslineModeVisual",  { fg = c.bg0, bg = c.rose, bold = true })
  set("MiniStatuslineDevIconAscii", { fg = c.fg0, bg = c.bg1 })
  set("SnacksBackdrop", { bg = c.bg0 })
  set("SnacksPickerDir", { fg = c.fg2 })
  set("SnacksPickerPathHidden", { fg = c.border })
  set("MiniIconsBlue",   { fg = c.ice })
  set("MiniIconsRed",    { fg = c.red1 })
  set("MiniIconsOrange", { fg = c.orange })
  set("MiniIconsYellow", { fg = c.yellow })

-- =========================================================
  -- RENDER MARKDOWN (TechRedDark Native)
  -- =========================================================

  -- Configuración de Encabezados (Texto y Estilo)
  set("RenderMarkdownH1", { fg = c.red1, bg = c.vinotinto, bold = true })
  set("RenderMarkdownH2", { fg = c.red2, bg = c.bg3, bold = true })
  set("RenderMarkdownH3", { fg = c.orange, bg = c.bg2, bold = true })
  set("RenderMarkdownH4", { fg = c.coral, bold = true })
  set("RenderMarkdownH5", { fg = c.yellow, bold = true })
  set("RenderMarkdownH6", { fg = c.gold, bold = true })

  -- Sincronización de Fondos (Bg) para evitar herencias de DiffAdd
  -- Vinculamos el fondo al mismo grupo para mantener la coherencia visual
  set("RenderMarkdownH1Bg", { link = "RenderMarkdownH1" })
  set("RenderMarkdownH2Bg", { link = "RenderMarkdownH2" })
  set("RenderMarkdownH3Bg", { link = "RenderMarkdownH3" })
  set("RenderMarkdownH4Bg", { link = "RenderMarkdownH4" })
  set("RenderMarkdownH5Bg", { link = "RenderMarkdownH5" })
  set("RenderMarkdownH6Bg", { link = "RenderMarkdownH6" })

  -- Componentes de Contenido
  set("RenderMarkdownBold", { fg = c.white, bold = true }) -- Blanco puro TechRed
  set("RenderMarkdownBullet", { fg = c.red1, bold = true })
  set("RenderMarkdownLink", { fg = c.cian, underline = true, bold = true })
  set("RenderMarkdownCodeInline", { fg = c.gold, bg = c.bg2, bold = true })
  set("RenderMarkdownTableHead", { fg = c.red2, bold = true })
  set("RenderMarkdownTableRow", { fg = c.fg1 })
  
  -- Checkboxes (VDP Workflow)
  set("RenderMarkdownSuccess", { fg = c.mint, bold = true }) -- [x]
  set("RenderMarkdownTodo", { fg = c.grey })

end

M.setup = function()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "TechRedDark"
  apply_ui()
  apply_syntax()
  apply_git()
  apply_lsp()
  apply_plugins()
end

return M