local M = {}
local _cache = { cpu_model = "Detecting...", pkg_count = "0", last_check = 0 }

function M.get_pkg_count()
    local now = os.time()
    if now - _cache.last_check > 600 or _cache.pkg_count == "0" then
        local f = io.popen("pacman -Q | wc -l")
        _cache.pkg_count = f:read("*a"):gsub("\n", "") or "0"
        f:close()
        _cache.last_check = now
    end
    return _cache.pkg_count
end

function M.get_cpu_name()
    if _cache.cpu_model == "Detecting..." then
        local handle = io.popen("lscpu | grep 'Model name' | cut -d: -f2 | sed -e 's/^[ \\t]*//' -e 's/Processor//g' -e 's/with Radeon Graphics//g' -e 's/CPU//g'")
        _cache.cpu_model = handle:read("*a"):gsub("\n", ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
        handle:close()
    end
    return _cache.cpu_model
end

function M.get_gpu_usage()
    local handle = io.popen("cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null")
    local val = handle:read("*a"):gsub("\n", "")
    handle:close()
    return (val ~= "" and val) or "0"
end

return M