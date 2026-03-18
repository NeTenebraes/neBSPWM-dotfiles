local M = {}

function M.draw_bar(cr, x, y, w, perc, title, theme)
    local bar_h = 5
    cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 10)
    
    -- Texto: Título y Porcentaje (Limpio, sin corchetes)
    cairo_set_source_rgba(cr, 1, 1, 1, 1) 
    cairo_move_to(cr, x, y - 6)
    -- Usamos un formato más simple: "TITULO | 50%"
    cairo_show_text(cr, title .. " | " .. math.floor(perc) .. "%")
    
    -- Fondo de la barra
    cairo_set_source_rgba(cr, 1, 1, 1, 0.1)
    cairo_rectangle(cr, x, y, w, bar_h)
    cairo_fill(cr)
    
    -- Progreso de la barra
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_rectangle(cr, x, y, w * (perc/100), bar_h)
    cairo_fill(cr)
end

function M.draw_background(cr, w, h, color, radius)
    cairo_set_source_rgba(cr, table.unpack(color))
    cairo_move_to(cr, radius, 0)
    cairo_line_to(cr, w - radius, 0)
    cairo_curve_to(cr, w, 0, w, 0, w, radius)
    cairo_line_to(cr, w, h - radius)
    cairo_curve_to(cr, w, h, w, h, w - radius, h)
    cairo_line_to(cr, radius, h)
    cairo_curve_to(cr, 0, h, 0, h, 0, h - radius)
    cairo_line_to(cr, 0, radius)
    cairo_curve_to(cr, 0, 0, 0, 0, radius, 0)
    cairo_fill(cr)
end

-- Función para dibujo de barra limpia (sin texto forzado)
function M.draw_bar_clean(cr, x, y, w, perc, theme)
    local bar_h = 4
    -- Fondo
    cairo_set_source_rgba(cr, 1, 1, 1, 0.1)
    cairo_rectangle(cr, x, y, w, bar_h)
    cairo_fill(cr)
    
    -- Progreso (Color de acento)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_rectangle(cr, x, y, w * (perc/100), bar_h)
    cairo_fill(cr)
end
return M