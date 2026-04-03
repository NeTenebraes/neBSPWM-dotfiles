require 'cairo'
require 'cairo_xlib'

local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.config/conky/lua/?.lua;" .. home .. "/.config/conky/lua/scripts/?.lua"

local theme = require("theme")
local draw  = require("draw_lib")
local net_data = require("network_data")

function conky_network_main()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    draw.draw_background(cr, conky_window.width, conky_window.height, theme.colors.bg, theme.dimensions.corner_radius)

    -- Datos
    local iface = conky_parse("${if_up proton0}proton0${else}${if_up tun0}tun0${else}${gw_iface}${endif}${endif}")
    local icon = net_data.get_iface_icon(iface)
    local dns_name = net_data.get_dns_name()
    local ping_val = net_data.get_ping()
    
    -- 1. TÍTULO PRINCIPAL (Size 22)
    cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 22)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_move_to(cr, 20, 40)
    cairo_show_text(cr, "󰀂 NETWORK")

    -- 2. BLOQUE DNS (A la derecha, igual que Storage)
    -- Línea 1: Icono y Label (Opacidad 1)
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 1, 1, 1, 1) -- Opacidad total
    cairo_move_to(cr, 180, 30) -- Ajustado a la derecha
    cairo_show_text(cr, "󰬦 DNS")

    -- Línea 2: Nombre del Servidor (Opacidad 0.4)
    cairo_set_font_size(cr, 10)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.4) 
    cairo_move_to(cr, 180, 45)
    cairo_show_text(cr, dns_name:upper())

    -- Línea separadora
    cairo_set_line_width(cr, 1)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.15)
    cairo_move_to(cr, 20, 52)
    cairo_line_to(cr, 240, 52)
    cairo_stroke(cr)

    -- 3. STATUS (Interfaz y Ping)
    cairo_set_font_size(cr, 10)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    
    cairo_move_to(cr, 20, 75)
    cairo_show_text(cr, icon .. " " .. iface:upper()) 
    
    cairo_move_to(cr, 200, 75)
    cairo_show_text(cr, "󰓅 " .. ping_val)

    -- 4. VELOCIDADES
    local up_f = tonumber(conky_parse("${upspeedf " .. iface .. "}")) or 0
    local down_f = tonumber(conky_parse("${downspeedf " .. iface .. "}")) or 0
    
    local up_p = math.min((up_f/2048)*100, 100)      
    local down_p = math.min((down_f/10240)*100, 100) 

    local up_label = "󰕒 UP: " .. conky_parse("${upspeed " .. iface .. "}") .. " | " .. conky_parse("${totalup " .. iface .. "}")
    local down_label = "󰇚 DOWN: " .. conky_parse("${downspeed " .. iface .. "}") .. " | " .. conky_parse("${totaldown " .. iface .. "}")

    draw.draw_bar(cr, 20, 105, 220, up_p, up_label, theme)
    draw.draw_bar(cr, 20, 145, 220, down_p, down_label, theme)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end