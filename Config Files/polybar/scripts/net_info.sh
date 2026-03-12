#!/bin/bash

active_index_file="$HOME/.config/polybar/scripts/active_net_index"
mkdir -p "$(dirname "$active_index_file")"

# 1. Interfaces reales
mapfile -t real_interfaces < <(
    ip -4 addr show | awk '/inet / && $NF != "lo" {print $NF}'
)

# 2. Creamos la lista: CENSORED siempre es la primera (índice 0)
interfaces=("CENSORED" "${real_interfaces[@]}")

# 3. Índice actual (Si no existe, el default es 0 = CENSORED)
if [ ! -f "$active_index_file" ]; then
    echo 0 > "$active_index_file"
fi

active_index=$(cat "$active_index_file")

# Validar que el índice sea válido tras cambios de hardware
if [ "$active_index" -ge "${#interfaces[@]}" ]; then
    active_index=0
    echo "$active_index" > "$active_index_file"
fi

# 4. Clicks (Navegación)
case "$1" in
    prev)
        active_index=$(( (active_index - 1 + ${#interfaces[@]}) % ${#interfaces[@]} ))
        echo "$active_index" > "$active_index_file"
        exit 0
        ;;
    next)
        active_index=$(( (active_index + 1) % ${#interfaces[@]} ))
        echo "$active_index" > "$active_index_file"
        exit 0
        ;;
esac

# 5. Lógica de visualización
active_iface=${interfaces[$active_index]}

if [ "$active_iface" = "CENSORED" ]; then
    icon="%{T1}󰦝%{T-}"
    display_name="LOCAL IP"
    ip_addr="CENSORED"
else
    ip_addr=$(ip -4 addr show "$active_iface" | awk '/inet / {print $2}' | cut -d'/' -f1 | head -1)
    display_name="$active_iface"

    case "$active_iface" in
        vmnet*|vmware*|vboxnet*) icon="%{T1}󰝨%{T-}" ;;
        enp*u*|enp*us*|enx*|usb*) icon="%{T1}%{T-}" ;; # Tethering
        eth*|enp*)               icon="%{T1}󰈀%{T-}" ;; # Ethernet
        wlan*|wlp*)              icon="%{T1}󰖩%{T-}" ;; # WiFi
        tun*|ppp*)               icon="%{T1}󰞉%{T-}" ;; # VPN
        *)                       icon="%{T1}󰤨%{T-}" ;;
    esac
fi

# 6. Salida para polybar
echo "%{A1:~/.config/polybar/scripts/net_info.sh prev:}${icon} %{T0}${display_name}: ${ip_addr}%{T-}%{A}%{A3:~/.config/polybar/scripts/net_info.sh next:}%{A}"