require 'cairo'
require 'cairo_xlib'

local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.config/conky/lua/?.lua;" .. home .. "/.config/conky/lua/scripts/?.lua"

local theme = require("theme")
local draw  = require("draw_lib")
local storage_data = require("storage_data")

function conky_storage_main()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    draw.draw_background(cr, conky_window.width, conky_window.height, theme.colors.bg, theme.dimensions.corner_radius)

    local drives = storage_data.get_mounted_drives()
    local n = #drives
    if n == 0 then return end

    -- 1. TÍTULO PRINCIPAL (Size 22)
    cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 22)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_move_to(cr, 20, 40)
    cairo_show_text(cr, "󰋊 STORAGE")

    -- 2. METADATA DERECHA (Size 12)
    local disk_io = conky_parse("${diskio}")
    cairo_set_font_size(cr, 12) 
    cairo_set_source_rgba(cr, 1, 1, 1, 0.4) 
    cairo_move_to(cr, 280, 38)
    cairo_show_text(cr, string.format("󰛨 I/O: %s | 󱔗 DEVS: %d", disk_io, n))

    -- LÍNEA SEPARADORA
    cairo_set_line_width(cr, 1)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.15)
    cairo_move_to(cr, 20, 52)
    cairo_line_to(cr, 480, 52)
    cairo_stroke(cr)

    ---------------------------------------------------------
    -- REJILLA ULTRA-DINÁMICA (Altura 150px)
    ---------------------------------------------------------
    local cols = 4
    if n <= 2 then cols = 1 
    elseif n <= 4 then cols = 2 
    end
    
    local row_height = (n > 8) and 32 or 42
    
    -- AJUSTE DE ALTURAS FINAL:
    -- n > 8: 70px (Máxima densidad para 12 discos)
    -- n <= 8: 80px (Balanceado para modo 1 col, 2 cols y 4 cols)
    local start_y = (n > 8) and 70 or 80
    
    local start_x = 20
    local col_width = (conky_window.width - 40) / cols

    for i, drive in ipairs(drives) do
        if i > 12 then break end

        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = start_x + (col * col_width)
        local y = start_y + (row * row_height)
        
        -- Datos de Conky (Manejo de rutas especiales como MTP)
        local perc = tonumber(conky_parse("${fs_used_perc " .. drive.path .. "}")) or 0
        local used = conky_parse("${fs_used " .. drive.path .. "}")
        -- Si el tamaño no viene definido por el script (MTP), lo pedimos a Conky
        local size = (drive.size and drive.size ~= "N/A") and drive.size or conky_parse("${fs_size " .. drive.path .. "}")

        -- NOMBRE DEL DISCO (Lógica de iconos integrada en storage_data)
        local font_status = (n > 8) and 9 or 10
        cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
        cairo_set_font_size(cr, font_status)
        cairo_set_source_rgba(cr, 1, 1, 1, 1)
        cairo_move_to(cr, x, y)
        cairo_show_text(cr, storage_data.get_storage_icon(drive.path) .. " " .. drive.name)
        
        -- INFO TÉCNICA
        cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
        local info_font = (n <= 2) and 9 or 8
        cairo_set_font_size(cr, info_font)
        cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
        
        if n > 8 then
            -- MODO COMPACTO (+8 dispositivos)
            cairo_move_to(cr, x + 10, y + 9)
            cairo_show_text(cr, drive.fstype .. " | " .. size)
            draw.draw_bar_clean(cr, x, y + 13, col_width - 35, perc, theme)
        elseif n <= 2 then
            -- MODO UNA COLUMNA (Elegante, estilo Network)
            cairo_move_to(cr, x, y + 12)
            cairo_show_text(cr, string.format("%s | USED: %s/%s", drive.fstype, used, size))
            draw.draw_bar_clean(cr, x, y + 18, col_width - 8, perc, theme)
        else
            -- MODO ESTÁNDAR (3-8 dispositivos)
            cairo_move_to(cr, x, y + 12)
            cairo_show_text(cr, drive.fstype .. " | " .. size)
            draw.draw_bar_clean(cr, x, y + 18, col_width - 35, perc, theme)
        end
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end