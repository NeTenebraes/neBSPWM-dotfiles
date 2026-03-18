require 'cairo'
require 'cairo_xlib'

local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.config/conky/lua/?.lua;" .. home .. "/.config/conky/lua/scripts/?.lua"

local theme = require("theme")
local draw  = require("draw_lib")
local system_data = require("system_data")

local function get_os_name()
    local handle = io.popen("grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '\"'")
    local os_id = handle:read("*a"):gsub("%s+", ""):upper()
    handle:close()
    return os_id ~= "" and os_id or "LINUX"
end

function conky_system_main()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    draw.draw_background(cr, conky_window.width, conky_window.height, theme.colors.bg, theme.dimensions.corner_radius)

    -- 1. RELOJ, FECHA Y METADATOS
    cairo_select_font_face(cr, "JetBrainsMono Nerd Font", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    
    cairo_set_font_size(cr, 48)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_move_to(cr, 20, 50)
    cairo_show_text(cr, os.date("%H:%M"))

    cairo_set_font_size(cr, 10)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.6) 
    cairo_move_to(cr, 22, 65) 
    cairo_show_text(cr, "󰸗 " .. os.date("%A, %d %b"):upper())

    -- BLOQUE SUPERIOR DERECHO (ORDEN: OS, KRNL, ENTR, PKGS, UPTM)
    local col_x = 170 
    cairo_set_font_size(cr, 9) 
    
    -- OS & Kernel (Color más tenue)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.8)
    cairo_move_to(cr, col_x, 25)
    cairo_show_text(cr, "󰣖 OS:   " .. get_os_name())

    local raw_k = conky_parse("${kernel}")
    local clean_k = raw_k:match("^(%d+%.%d+%.%d+)") or "Linux"
    cairo_move_to(cr, col_x, 35)
    cairo_show_text(cr, "󰌽 KRNL: " .. clean_k)

    -- Metadatos de uso (Color normal)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.5)
    cairo_move_to(cr, col_x, 45)
    cairo_show_text(cr, "󰆧 ENTR: " .. conky_parse("${entropy_avail}"))

    cairo_move_to(cr, col_x, 55)
    cairo_show_text(cr, "󰏖 PKGS: " .. system_data.get_pkg_count())

    cairo_move_to(cr, col_x, 65)
    cairo_show_text(cr, "󱎫 UPTM: " .. conky_parse("${uptime_short}"))

    -- Separador
    cairo_set_line_width(cr, 1)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_move_to(cr, 20, 80)
    cairo_line_to(cr, 240, 80) 
    cairo_stroke(cr)

    -- 2. CPU INFO
    local cpu_name = system_data.get_cpu_name()
    local cpu_temp = conky_parse("${hwmon 5 temp 1}") 
    cairo_set_font_size(cr, 11)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_move_to(cr, 20, 105)
    cairo_show_text(cr, " " .. cpu_name .. " (" .. cpu_temp .. "°C)")

    local cpu_gen = tonumber(conky_parse("${cpu cpu0}")) or 0
    local cpu_freq = conky_parse("${freq_g}")
    draw.draw_bar(cr, 20, 130, 220, cpu_gen, "CPU @ " .. cpu_freq .. "GHz", theme)

    -- 3. CORES LOAD
    cairo_set_font_size(cr, 10)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.9)
    cairo_move_to(cr, 20, 160)
    cairo_show_text(cr, "󰻠 CORES LOAD")

    local threads = tonumber(conky_parse("${cpu cpu0}")) and debug.getregistry().conky_ncpus or 4
    local cores_per_row = math.ceil(threads / 2)
    local gap = 5
    local total_width = 220
    local bar_width = (total_width - (gap * (cores_per_row - 1))) / cores_per_row

    for i=1, threads do
        local row = (i <= cores_per_row) and 0 or 1
        local col = (i <= cores_per_row) and (i - 1) or (i - cores_per_row - 1)
        local x = 20 + (col * (bar_width + gap))
        local y = 185 + (row * 25)
        local usage = tonumber(conky_parse("${cpu cpu" .. i .. "}")) or 0
        draw.draw_bar(cr, x, y, bar_width, usage, "󰻠 " .. i, theme)
    end

    -- 4. GPU, RAM Y SWAP
    local gpu_p = tonumber(system_data.get_gpu_usage()) or 0
    draw.draw_bar(cr, 20, 240, 220, gpu_p, "󰢮 RADEON R3", theme)
    
    local ram_p = tonumber(conky_parse("${memperc}")) or 0
    draw.draw_bar(cr, 20, 280, 220, ram_p, "󰑭 RAM: " .. conky_parse("${mem}"), theme)
    
    local swp_p = tonumber(conky_parse("${swapperc}")) or 0
    draw.draw_bar(cr, 20, 310, 220, swp_p, "󰓡 SWAP: " .. conky_parse("${swap}"), theme)

    -- 5. TOP PROCESSES
    local top_y = 340
    cairo_set_font_size(cr, 11)
    cairo_set_source_rgba(cr, table.unpack(theme.colors.accent))
    cairo_move_to(cr, 20, top_y)
    cairo_show_text(cr, "󰣖 PROCESSES")

    cairo_set_font_size(cr, 9)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.4)
    cairo_move_to(cr, 20, top_y + 18)
    cairo_show_text(cr, "NAME")
    cairo_move_to(cr, 150, top_y + 18)
    cairo_show_text(cr, "CPU%")
    cairo_move_to(cr, 200, top_y + 18)
    cairo_show_text(cr, "MEM%")

    cairo_set_source_rgba(cr, 1, 1, 1, 0.8)
    for i=1, 3 do
        local offset = top_y + 20 + (i * 15)
        cairo_move_to(cr, 20, offset)
        cairo_show_text(cr, string.upper(conky_parse("${top name " .. i .. "}")))
        cairo_move_to(cr, 140, offset)
        cairo_show_text(cr, conky_parse("${top cpu " .. i .. "}") .. "%")
        cairo_move_to(cr, 190, offset)
        cairo_show_text(cr, conky_parse("${top mem " .. i .. "}") .. "%")
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end