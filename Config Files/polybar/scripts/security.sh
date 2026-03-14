#!/usr/bin/env bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

ICON_FW="security-high"
ICON_VPN="network-vpn-symbolic"
ICON_OFF="network-error-symbolic"
ICON_ALERT="dialog-warning-symbolic"

case "$LANG" in
    es*)
        T_FW="CORTAFUEGOS"
        T_VPN="VPN"
        L_ENGINE="Motor"
        L_STATUS="Estado"
        L_IFACE="Interfaz"
        L_PUBLIC_IP="IP pública"
        L_ON="ACTIVO"
        L_OFF="DESACTIVADO"
        L_HIDDEN="OCULTA"
        L_NONE="NINGUNA"
        ;;
    *)
        T_FW="FIREWALL"
        T_VPN="VPN"
        L_ENGINE="Engine"
        L_STATUS="Status"
        L_IFACE="Interface"
        L_PUBLIC_IP="Public IP"
        L_ON="ACTIVE"
        L_OFF="DISABLED"
        L_HIDDEN="HIDDEN"
        L_NONE="NONE"
        ;;
esac

get_vpn_iface() {
    ip -o link show up | awk -F': ' '/(tun|ppp|wg|proton|ipvpn)/ {print $2; exit}'
}

get_public_ip() {
    curl -s --max-time 1.5 ifconfig.me || echo "---"
}

get_firewall_info() {
    if [ -f /etc/ufw/ufw.conf ] && grep -q "ENABLED=yes" /etc/ufw/ufw.conf; then
        echo "UFW|$L_ON|$ICON_FW"
    elif systemctl is-active --quiet firewalld; then
        echo "Firewalld|$L_ON|$ICON_FW"
    elif systemctl is-active --quiet nftables; then
        echo "nftables|$L_ON|$ICON_FW"
    else
        echo "None|$L_OFF|$ICON_ALERT"
    fi
}

notify_fw() {
    IFS='|' read -r engine status icon <<< "$(get_firewall_info)"
    notify-send -u normal -t 5000 -i "$icon" \
        "$T_FW" \
        "$L_ENGINE: $engine
$L_STATUS: $status"
}

notify_vpn() {
    local iface pub_ip urgency icon status
    iface="$(get_vpn_iface)"

    if [ -n "$iface" ]; then
        status="$L_ON"
        pub_ip="$(get_public_ip)"
        urgency="normal"
        icon="$ICON_VPN"
    else
        status="$L_OFF"
        pub_ip="$L_HIDDEN"
        urgency="critical"
        icon="$ICON_OFF"
    fi

    notify-send -u "$urgency" -t 5000 -i "$icon" \
        "$T_VPN" \
        "$L_STATUS: $status
$L_IFACE: ${iface:-$L_NONE}
$L_PUBLIC_IP: $pub_ip"
}

notify_all() {
    notify_fw
    notify_vpn
}

phase=$(( ($(date +%s) / 5) % 2 ))

case "${1:-}" in
    --notify-all)
        notify_all
        exit 0
        ;;
esac

if [ "$phase" -eq 0 ]; then
    IFS='|' read -r engine status icon <<< "$(get_firewall_info)"
    [ "$status" = "$L_ON" ] && echo "%{F#44FF44}󰒘%{F-}" || echo "%{F#777777}󰦝%{F-}"
else
    iface="$(get_vpn_iface)"
    [ -n "$iface" ] && echo "%{F#00FFFF}󰞉%{F-}" || echo "%{F#777777}󰞉%{F-}"
fi
