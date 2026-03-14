#!/usr/bin/env bash

index_file="/tmp/net_idx"
time_file="/tmp/net_last_change"
timer_pid_file="/tmp/net_refresh_timer.pid"
module_name="#network-cycle.hook.0"

[ -f "$index_file" ] || echo 0 > "$index_file"

mapfile -t ifaces < <(
    printf '%s\n' "CENSORED"
    ip -4 addr show | awk '/inet / && $NF != "lo" {print $NF}'
)

[ "${#ifaces[@]}" -gt 0 ] || ifaces=("CENSORED")

refresh_now() {
    polybar-msg action "$module_name" >/dev/null 2>&1
}

cancel_timer() {
    if [ -f "$timer_pid_file" ]; then
        old_pid="$(cat "$timer_pid_file" 2>/dev/null)"
        if [ -n "${old_pid:-}" ] && kill -0 "$old_pid" 2>/dev/null; then
            kill "$old_pid" 2>/dev/null
        fi
        rm -f "$timer_pid_file"
    fi
}

schedule_collapse() {
    cancel_timer
    (
        sleep 5
        polybar-msg action "$module_name" >/dev/null 2>&1
        rm -f "$timer_pid_file"
    ) &
    echo $! > "$timer_pid_file"
}

read_index() {
    idx="$(cat "$index_file" 2>/dev/null)"
    idx="${idx:-0}"
    if ! [[ "$idx" =~ ^[0-9]+$ ]]; then
        idx=0
    fi
    if [ "${#ifaces[@]}" -gt 0 ]; then
        idx=$(( idx % ${#ifaces[@]} ))
    else
        idx=0
    fi
}

write_index() {
    echo "$idx" > "$index_file"
}

show_output() {
    local iface icon ip_addr show_full=false last_change current_time

    read_index
    iface="${ifaces[$idx]}"

    case "$iface" in
        proton*|tun*|ppp*|wg*|tailscale*|zt*) icon="󰞉" ;;   # VPN
        vmnet*|virbr*|docker*|br-* )          icon="󰝨" ;;   # Virtuales
        enp*u*)                               icon="" ;;   # USB tethering
        eth*|eno*|enp*)                       icon="󰈀" ;;   # Ethernet
        wlan*|wlp*)                           icon="󰖩" ;;   # Wi‑Fi
        CENSORED)                             icon="󰦝" ;;
        *)                                    icon="󰖈" ;;
    esac

    if [ "$iface" = "CENSORED" ]; then
        echo "${icon} %{F#777777}HIDDEN%{F-}"
        exit 0
    fi

    ip_addr="$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1 | head -1)"
    [ -n "$ip_addr" ] || ip_addr="NO IP"

    if [ -f "$time_file" ]; then
        last_change="$(cat "$time_file" 2>/dev/null)"
        current_time="$(date +%s)"
        if [[ "${last_change:-}" =~ ^[0-9]+$ ]] && (( current_time - last_change < 5 )); then
            show_full=true
        fi
    fi

    if [ "$show_full" = true ]; then
        echo "${icon} ${iface}: ${ip_addr}"
    else
        echo "${icon} ${ip_addr}"
    fi
}

case "${1:-}" in
    prev|next)
        read_index
        count="${#ifaces[@]}"
        [ "$count" -gt 0 ] || exit 0

        if [ "$1" = "prev" ]; then
            idx=$(( (idx - 1 + count) % count ))
        else
            idx=$(( (idx + 1) % count ))
        fi

        write_index
        date +%s > "$time_file"
        refresh_now
        schedule_collapse
        exit 0
        ;;
esac

show_output
