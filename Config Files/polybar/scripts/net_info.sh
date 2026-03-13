#!/bin/bash

index_file="/tmp/net_idx"
time_file="/tmp/net_last_change"
[ ! -f "$index_file" ] && echo 0 > "$index_file"

mapfile -t ifaces < <(echo "CENSORED"; ip -4 addr show | awk '/inet / && $NF != "lo" {print $NF}')
idx=$(cat "$index_file")

# Navegación
if [[ "$1" == "prev" || "$1" == "next" ]]; then
    [ "$1" == "prev" ] && idx=$(( (idx - 1 + ${#ifaces[@]}) % ${#ifaces[@]} )) || idx=$(( (idx + 1) % ${#ifaces[@]} ))
    echo "$idx" > "$index_file"
    # Guardamos el segundo exacto del clic
    date +%s > "$time_file"
    exit 0
fi

iface=${ifaces[$idx]}

# Lógica de Iconos
case "$iface" in
    vmnet*)    icon="󰝨" ;;
    enp*u*)    icon="" ;; 
    eth*|enp*) icon="󰈀" ;; 
    wlan*|wlp*) icon="󰖩" ;; 
    tun*|ppp*) icon="󰞉" ;; 
    CENSORED)  icon="󰦝" ;;
    *)         icon="󰤨" ;;
esac

if [ "$iface" = "CENSORED" ]; then
    echo "%{A1:$0 prev:}%{A3:$0 next:}${icon} %{F#777777}HIDDEN%{F-}%{A}%{A}"
else
    ip_addr=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d'/' -f1 | head -1)
    
    # Comprobar si han pasado menos de 5 segundos desde el último clic
    show_full=false
    if [ -f "$time_file" ]; then
        last_change=$(cat "$time_file")
        current_time=$(date +%s)
        # Diferencia de tiempo
        if (( current_time - last_change < 5 )); then
            show_full=true
        fi
    fi

    if [ "$show_full" = true ]; then
        display="${iface}: ${ip_addr}"
    else
        display="${ip_addr}"
    fi

    echo "%{A1:$0 prev:}%{A3:$0 next:}${icon} ${display}%{A}%{A}"
fi