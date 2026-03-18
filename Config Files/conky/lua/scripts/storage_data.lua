local M = {}

function M.get_mounted_drives()
    local drives = {}
    
    -- 1. Discos Físicos (lsblk)
    -- Quitamos /run/user del filtro negativo para permitir GVFS si lsblk lo ve
    local handle = io.popen("lsblk -nr -o MOUNTPOINT,SIZE,FSTYPE | grep -E '^/' | grep -vE '^/boot|^/efi'")
    
    for line in handle:lines() do
        local mount, size, fstype = line:match("^(%S+)%s+(%S+)%s+(%S+)")
        if mount and #drives < 12 then
            local name = (mount == "/" and "ROOT" or mount:match("([^/]+)$") or mount):upper()
            table.insert(drives, {
                path = mount,
                name = name,
                size = size,
                fstype = (fstype or "UNK"):upper()
            })
        end
    end
    handle:close()

    -- 2. Detección de Smartphone (MTP/GVFS)
    -- Si no fue detectado por lsblk, lo buscamos en la ruta que encontraste
    local gvfs_path = "/run/user/1000/gvfs"
    local phone_handle = io.popen("ls " .. gvfs_path .. " 2>/dev/null")
    for device in phone_handle:lines() do
        if device:find("mtp") then
            -- Limpiamos el nombre: "mtp:host=Xiaomi_POCO_F3_ecba709c" -> "POCO F3"
            local clean_name = device:match("host=(.*)") or device
            clean_name = clean_name:gsub("_", " "):gsub("ecba709c", ""):upper()
            
            table.insert(drives, {
                path = gvfs_path .. "/" .. device,
                name = clean_name,
                size = "N/A", -- MTP a veces no reporta tamaño total vía CLI fácilmente
                fstype = "MTP"
            })
        end
    end
    phone_handle:close()

    return drives
end

function M.get_storage_icon(path)
    if path == "/" then return "󰋊" end 
    if path:find("gvfs") or path:find("mtp") then return "󰄜" end -- Icono de Celular
    if path:find("/mnt") or path:find("/media") or path:find("/run/media") then return "󱊞" end
    return "󰋊" 
end

return M