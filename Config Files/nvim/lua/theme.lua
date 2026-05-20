-- =========================================================
-- theme.lua
-- Tema rojo/oscuro para Neovim.
--
-- Criterio de diseño:
-- - UI: Fondos negros rojizos profundos para mitigar fatiga visual.
-- - Sintaxis: Variantes cálidas (fuegos, melocotones, rosas).
-- - Colores fríos: Reservados estrictamente para contrastes localizados (LSP/Escapes).
-- =========================================================

local M = {}

-- Paleta de colores estructurada
M.colors = {
  -- Fondos (UI y Editores)
  bg0    = "#090507", -- Negro rojizo ultra profundo (Fondo principal)
  bg1    = "#160b10", -- Negro vino sutil (CursorLine y bloques secundarios)
  bg2    = "#211118", -- Tono medio (Ventanas flotantes y menús)
  bg3    = "#301721", -- Tono claro de control (Selección visual / Resaltados)
  border = "#5e2230", -- Bordes y líneas divisorias (Tono vino seco)

  -- Texto base y jerarquías
  fg0    = "#f4dfd8", -- Texto principal (Blanco cálido/rosáceo)
  fg1    = "#dcc7c0", -- Texto secundario (Gris apagado cálido)
  fg2    = "#b79a95", -- Texto terciario / Comentarios
  white  = "#fff6f3", -- Blanco puro brillante para acentos

  -- Colores de sintaxis principales
  red1   = "#ef4761", -- Rojo vivo (Keywords, control de flujo)
  red2   = "#f06a7f", -- Rojo medio (Funciones y etiquetas HTML)
  rose   = "#f2a6b3", -- Rosa pastel (Strings y literales de texto)
  orange = "#e8a15b", -- Naranja fuego (Tipos de datos y atributos)
  peach  = "#f2b8a0", -- Melocotón (Números, constantes y valores CSS)
  wine   = "#8a3345", -- Carmín oscuro (Bloques visuales y emparejamientos)

  -- Colores de rescate para contraste específico
  yellow = "#f1d67a", -- Amarillo (Alertas, selectores CSS e identificadores)
  ice    = "#b8dff2", -- Azul gélido (Diagnósticos y secuencias de escape)
}

local hl = vim.api.nvim_set_hl

-- Wrapper para simplificar la asignación de grupos de resaltado
local function set(group, opts)
  hl(0, group, opts)
end

-- =========================================================
-- CONTROLES DE LA INTERFAZ DE USUARIO (UI)
-- =========================================================
local function apply_ui(c)
  set("Normal",       { fg = c.fg0, bg = c.bg0 }) -- Texto y fondo principal
  set("NormalNC",     { fg = c.fg1, bg = c.bg0 }) -- Ventanas sin foco activo
  set("EndOfBuffer",  { fg = c.bg0, bg = c.bg0 }) -- Ocultar las tildes (~) del final del archivo
  set("SignColumn",   { bg = c.bg0 })             -- Columna izquierda para iconos de Git/LSP
  set("LineNr",       { fg = c.border, bg = c.bg0 }) -- Números de línea inactivos
  set("CursorLineNr", { fg = c.white, bg = c.bg0, bold = true }) -- Número de línea actual

  -- Ajustes de movimiento y selección
  set("CursorLine",   { bg = "#12080d" }) -- Franja de la línea actual (Vino ultra oscuro discreto)
  set("Visual",       { fg = c.white, bg = c.wine }) -- Selección de texto (Bloque vino con letras blancas)
  set("Search",       { fg = c.bg0, bg = c.rose, bold = true }) -- Búsquedas estáticas
  set("IncSearch",    { fg = c.bg0, bg = c.red1, bold = true }) -- Búsqueda incremental interactiva

  -- Separadores y paneles
  set("VertSplit",    { fg = c.border, bg = c.bg0 })
  set("WinSeparator", { fg = c.border, bg = c.bg0 })
  set("ColorColumn",  { bg = c.bg1 }) -- Columna límite (ej. columna 80)

  -- Textos invisibles o especiales
  set("Comment",    { fg = c.fg2, italic = true })
  set("NonText",    { fg = c.fg2, bg = c.bg0 })
  set("SpecialKey", { fg = c.rose, bg = c.bg3, bold = true })

  -- Ventanas flotantes y menús contextuales
  set("NormalFloat", { fg = c.fg0, bg = c.bg2 })
  set("FloatBorder", { fg = c.red1, bg = c.bg2 })
  
  -- Menú de autocompletado (Cmp / Omnifunc)
  set("Pmenu",      { fg = c.fg1, bg = c.bg2 })          -- Fondo general
  set("PmenuSel",   { fg = c.bg0, bg = c.red1, bold = true }) -- Elemento seleccionado
  set("PmenuSbar",  { bg = c.bg2 })                      -- Barra de desplazamiento
  set("PmenuThumb", { bg = c.border })                   -- Indicador de posición

  -- Barras de estado y pestañas (Tablines)
  set("WinBar",      { fg = c.fg0, bg = c.bg1, bold = true })
  set("WinBarNC",    { fg = c.fg2, bg = c.bg0 })
  set("TabLine",     { fg = c.fg0, bg = c.bg1 })
  set("TabLineSel",  { fg = c.bg0, bg = c.red1, bold = true })
  set("TabLineFill", { bg = c.bg0 })

  -- Cursores nativos del sistema
  set("Cursor",       { fg = c.bg0, bg = c.red1 })
  set("TermCursor",   { fg = c.bg0, bg = c.red1 })
end

-- =========================================================
-- CONFIGURACIÓN DE SINTAXIS RECONOCIDA (Sintaxis Estándar y Tree-sitter)
-- =========================================================
local function apply_syntax(c)
  -- Sintaxis Clásica de Vim (Fallbacks del editor)
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
  set("cFormat",      { fg = c.yellow, bold = true })
  set("cSpecial",     { fg = c.ice, bold = true })

  -- Paréntesis y Delimitadores (MatchParen controlado)
  set("@punctuation.bracket", { fg = c.orange })
  set("@punctuation.delimiter", { fg = c.peach })
  set("@operator", { fg = c.red1, bold = true })
  set("MatchParen", { fg = c.white, bg = c.wine, bold = true }) -- Pareja de paréntesis bajo el cursor

  -- AST / Árboles genéricos de Tree-sitter
  set("@variable",         { fg = c.fg0, italic = true })
  set("@variable.member",  { fg = c.fg1 })
  set("@variable.builtin", { fg = c.orange, bold = true })
  set("@property",         { fg = c.fg1 })
  set("@string",           { fg = c.rose })
  set("@string.escape",    { fg = c.ice, bold = true })
  set("@function",         { fg = c.red2, bold = true })
  set("@function.call",    { fg = c.red2 })
  set("@function.builtin", { fg = c.red1, bold = true })
  set("@keyword",          { fg = c.red1, bold = true })
  set("@keyword.operator", { fg = c.red1 })
  set("@keyword.return",   { fg = c.red1, bold = true })
  set("@type",             { fg = c.orange, bold = true })
  set("@type.builtin",     { fg = c.orange, bold = true })
  set("@constant",         { fg = c.peach })
  set("@number",           { fg = c.peach })
  set("@boolean",          { fg = c.peach, bold = true })
  set("@comment",          { fg = c.fg2, italic = true })
  set("@punctuation",      { fg = c.border })
  set("@operator",         { fg = c.red1 })

  -- =========================================================
  -- ENTORNO DESARROLLO WEB (HTML & CSS)
  -- =========================================================
  
  -- Marcado HTML / JSX / Astro
  set("@tag",                  { fg = c.red1, bold = true })     -- Etiquetas (<body, <style, <div)
  set("@tag.builtin",          { fg = c.red1, bold = true })
  set("@tag.attribute",        { fg = c.orange, italic = true }) -- Atributos (charset, class, id)
  set("@tag.delimiter",        { fg = c.wine })                  -- Delimitadores (<, >, />)

  -- CSS Estándar (Archivos .css independientes)
  set("@type.tag.css",         { fg = c.red2 })             -- Selectores de etiqueta (body, textarea)
  set("@property.css",         { fg = c.fg0, bold = true }) -- Propiedades CSS (margin, background, resize)
  set("@string.css",           { fg = c.rose })             -- Rutas de fuentes o recursos (url)
  set("@number.css",           { fg = c.peach })            -- Dimensiones y unidades (20px, 1100px)
  set("@label.css",            { fg = c.yellow })           -- Selectores por clase (.container) o id
  set("@keyword.css",          { fg = c.red1 })             -- Directivas del preprocesador (@media)

  -- =========================================================
  -- EL REMEDIO PARA LOS VALORES EN CSS EMBEBIDO (HTML <style>)
  -- =========================================================
  -- Estos grupos rompen el comportamiento plano obligando a palabras como 'auto' o 'vertical'
  -- a usar el color melocotón en lugar de heredar el blanco plano de la propiedad.
  set("@keyword.modifier.css", { fg = c.peach }) -- Modificadores de CSS
  set("@keyword.value.css",    { fg = c.peach }) -- Constantes de valores CSS
  set("@constant.css",         { fg = c.peach }) -- Valores planos del sistema
  set("@string.plain.css",     { fg = c.peach }) -- Texto plano interpretado como valor en árboles modernos
  
  -- Forzados de inyección de lenguajes de Tree-sitter (CSS dentro de HTML)
  set("@variable.css",         { fg = c.peach })
  set("@variable.parameter.css", { fg = c.fg0, bold = true }) -- Respaldo de propiedad dentro de inyección
  set("cssValueKeyword",       { fg = c.peach }) -- Respaldo clásico de Vim Syntax

  -- Lenguajes adicionales de soporte
  -- JavaScript / TypeScript
  set("@constructor.javascript", { fg = c.orange, bold = true })
  set("@variable.parameter",     { fg = c.peach, italic = true })
  set("@keyword.import",         { fg = c.red1, bold = true })
  
  -- Bash / Shell Scripts
  set("@function.macro.bash",  { fg = c.red1 })
  set("@parameter.bash",       { fg = c.peach })
  set("@string.special.bash",  { fg = c.ice })
end

-- =========================================================
-- CONFIGURACIÓN DE COMPONENTES DE PLUGINS (Snacks, etc.)
-- =========================================================
local function apply_plugins(c)
  set("SnacksDashboardHeader", { fg = c.red1 })
  set("SnacksDashboardTitle",  { fg = c.red2, bold = true })
  set("SnacksDashboardIcon",   { fg = c.rose })
  set("SnacksDashboardDesc",   { fg = c.fg2 })
  set("SnacksDashboardKey",    { fg = c.orange })
  set("SnacksDashboardFile",   { fg = c.fg1 })
  set("SnacksDashboardDir",    { fg = c.fg2 })

  -- =========================================================
  -- CORRECCIÓN DE CONTRASTE PARA LAZY.NVIM
  -- =========================================================
  set("LazyNormal",      { fg = c.fg0, bg = c.bg2 })   -- Panel general un punto más claro
  set("LazyButton",      { fg = c.fg1, bg = c.bg3 })   -- Botones de la barra superior
  set("LazyButtonActive",{ fg = c.white, bg = c.wine, bold = true }) -- Botón seleccionado (p. ej. Update)
  set("LazySpecial",     { fg = c.orange })            -- Versiones y estados mutados
  set("LazyH1",          { fg = c.bg0, bg = c.red1, bold = true }) -- Título de secciones
  
  -- Los cuadros problemáticos de los plugins individuales:
  set("LazyProgressTodo", { fg = c.fg2, bg = c.bg1 })  -- Barra de progreso sin cargar
  set("LazyProgressDone", { fg = c.white, bg = c.wine }) -- Progreso completado
  set("LazyProp",         { fg = c.fg2 })              -- Propiedades internas de los plugins
  set("LazyComment",      { fg = c.fg2, italic = true }) -- Tiempos en ms y textos secundarios
end

-- =========================================================
-- INTEGRACIÓN CON CLIENTE LSP (Protocolo de Servidor de Lenguajes)
-- =========================================================
local function apply_lsp(c)
  -- Notificaciones y Diagnósticos de Errores integrados en la paleta
  set("DiagnosticError", { fg = c.red1 })
  set("DiagnosticWarn",  { fg = c.orange })
  set("DiagnosticInfo",  { fg = c.peach })
  set("DiagnosticHint",  { fg = c.ice })

  -- Iconos laterales en el buffer (SignColumn)
  set("DiagnosticSignError", { fg = c.red1, bg = c.bg0 })
  set("DiagnosticSignWarn",  { fg = c.orange, bg = c.bg0 })
  set("DiagnosticSignInfo",  { fg = c.peach, bg = c.bg0 })
  set("DiagnosticSignHint",  { fg = c.ice, bg = c.bg0 })

  -- Textos flotantes integrados al final de las líneas (VirtualText)
  set("DiagnosticVirtualTextError", { fg = c.red1, bg = c.bg1 })
  set("DiagnosticVirtualTextWarn",  { fg = c.orange, bg = c.bg1 })
  set("DiagnosticVirtualTextInfo",  { fg = c.peach, bg = c.bg1 })
  set("DiagnosticVirtualTextHint",  { fg = c.ice, bg = c.bg1 })

  -- Subrayados decorativos de errores
  set("DiagnosticUnderlineError", { undercurl = true, sp = c.red1 })
  set("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.orange })
  set("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.peach })
  set("DiagnosticUnderlineHint",  { undercurl = true, sp = c.ice })

  -- Sugerencias de tipado estático (Inlay Hints)
  set("LspInlayHint", { fg = c.fg2, bg = c.bg1, italic = true })

  -- =========================================================
  -- RESALTADO DINÁMICO DE REFERENCIAS LSP
  -- Esto controla el Extmark que se activa cuando pones el cursor encima de una palabra.
  -- Cambiamos el fondo opaco anterior por una iluminación de texto limpia y distinguible.
  -- =========================================================
  set("LspReferenceText",  { fg = c.peach, bg = c.bg1, bold = true }) -- Al leer referencias generales
  set("LspReferenceRead",  { fg = c.peach, bg = c.bg1, bold = true }) -- Al leer variables/propiedades bajo el cursor
  set("LspReferenceWrite", { fg = c.orange, bg = c.bg1, bold = true }) -- Al situarse en una escritura/mutación
end

-- =========================================================
-- FLUJO DE INICIALIZACIÓN DEL TEMA
-- =========================================================
function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "mi_tema_rojo"

  local c = M.colors
  
  -- El orden de ejecución importa: Cargamos UI, luego sintaxis sintáctica
  -- y dejamos los plugins/LSP al final asegurándonos de que sus referencias estén bien atadas.
  apply_ui(c)
  apply_syntax(c)
  apply_plugins(c)
  apply_lsp(c) -- Se ejecuta aquí limpiamente sin pisar tus grupos de UI
end

return M