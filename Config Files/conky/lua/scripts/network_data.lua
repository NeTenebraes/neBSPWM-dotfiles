local M = {}

-- Función para identificar el proveedor de DNS
function M.get_dns_name()
    local handle = io.popen("grep nameserver /etc/resolv.conf | head -n 1 | awk '{print $2}'")
    local dns_ip = handle:read("*a"):gsub("%s+", "")
    handle:close()

    if dns_ip == "1.1.1.1" or dns_ip == "1.0.0.1" then return "CLOUDFLARE"
    elseif dns_ip == "8.8.8.8" or dns_ip == "8.8.4.4" then return "GOOGLE"
    elseif dns_ip == "9.9.9.9" or dns_ip == "149.112.112.112" then return "QUAD9"
    elseif dns_ip == "208.67.222.222" or dns_ip == "208.67.220.220" then return "OPENDNS"
    elseif dns_ip:find("^192%.168") or dns_ip:find("^10%.") then return "LOCAL/ROUTER"
    elseif dns_ip == "" then return "NONE"
    else return "CUSTOM" end
end

function M.get_iface_icon(iface)
    -- 1. VPN (Prioridad máxima para auditoría/seguridad)
    if iface:find("tun") or iface:find("proton") or iface:find("wg") then
        return "󰖂" 
        
    -- 2. Wireless
    elseif iface:find("wl") then
        return "󰖩" 
        
    -- 3. Tethering USB (Detecta la cadena de puertos u3u1u3, usb o enx)
    -- Usamos '%du' para detectar el patrón de puerto USB en el nombre largo
    elseif iface:find("%du") or iface:find("usb") or iface:find("enx") then
        return "󰄜" -- Icono de Smartphone/USB
        
    -- 4. Ethernet (Cualquier otro que empiece por en, pero no sea USB)
    elseif iface:find("^en") or iface:find("eth") then
        return "󰈀" 
        
    else
        return "󰞀" 
    end
end
-- Función para obtener el ping limpio
function M.get_ping()
    -- Intervalo de 25s para no saturar, timeout de 5s por seguridad
    local ping_raw = conky_parse("${texeci 25 ping -c 1 -W 5 1.1.1.1 | grep 'time=' | awk -F'time=' '{print $2}' | cut -d ' ' -f 1}")
    if ping_raw ~= "" then
        local ms = ping_raw:match("(%d+)")
        return (ms or "0") .. "ms"
    end
    return "OFF"
end

return M