#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# --- ICONOS ---
ICON_FW="security-high"
ICON_VPN="network-vpn-symbolic"
ICON_OFF="network-error-symbolic" 
ICON_ALERT="dialog-warning-symbolic"

# Idiomas
case "$LANG" in
    es*) T_FW="CORTAFUEGOS"; T_VPN="VPN"; L_TYPE="Motor:"; L_STATUS="Estado:"; L_IP="IP Pública:"; L_OFF="DESACTIVADO"; L_ON="ACTIVO"; L_ISP="IP Proveedor:"; L_HIDDEN="OCULTA" ;;
    *)   T_FW="FIREWALL"; T_VPN="VPN"; L_TYPE="Engine:"; L_STATUS="Status:"; L_IP="Public IP:"; L_OFF="DISABLED"; L_ON="ACTIVE"; L_ISP="ISP IP:"; L_HIDDEN="HIDDEN" ;;
esac

get_vpn_iface() {
    ip addr | grep -E 'tun[0-9]|ppp[0-9]|wg[0-9]|proton|ipvpn' | awk -F: '{print $2}' | tr -d ' ' | head -1
}

get_firewall_info() {
    # 1. Verificación de UFW (La más precisa sin root)
    if [ -f /etc/ufw/ufw.conf ] && grep -q "ENABLED=yes" /etc/ufw/ufw.conf; then
        echo "UFW|$L_ON|$ICON_FW"
    # 2. Verificación de Firewalld
    elif systemctl is-active --quiet firewalld; then
        echo "Firewalld|$L_ON|$ICON_FW"
    # 3. Verificación de nftables
    elif systemctl is-active --quiet nftables; then
        echo "nftables|$L_ON|$ICON_FW"
    else
        echo "None|$L_OFF|$ICON_ALERT"
    fi
}

if [ "$1" == "--notify" ]; then
    rem=$(( $(date +%s) % 10 ))
    if [ $rem -lt 5 ]; then
        IFS='|' read -r engine status icon <<< "$(get_firewall_info)"
        notify-send -t 4000 -u normal -i "$icon" "$T_FW" "$L_TYPE $engine\n$L_STATUS $status"
    else
        iface=$(get_vpn_iface)
        if [ -n "$iface" ]; then
            PUB_IP=$(curl -s --max-time 1.5 ifconfig.me || echo "---")
            notify-send -t 4000 -u normal -i "$ICON_VPN" "$T_VPN" "$iface\n$L_IP $PUB_IP"
        else
            notify-send -t 4000 -u critical -i "$ICON_OFF" "$T_VPN" "$L_OFF\n$L_ISP $L_HIDDEN"
        fi
    fi
    exit 0
fi

# --- VISUALIZACIÓN POLYBAR ---
rem=$(( $(date +%s) % 10 ))
if [ $rem -lt 5 ]; then
    IFS='|' read -r engine status icon <<< "$(get_firewall_info)"
    if [ "$status" == "$L_ON" ]; then
        echo "%{F#44FF44}󰒘%{F-}" # Verde si está activo
    else
        echo "%{F#777777}󰦝%{F-}" # Gris si está desactivado
    fi
else
    iface=$(get_vpn_iface)
    [[ -n "$iface" ]] && echo "%{F#00FFFF}󰞉%{F-}" || echo "%{F#777777}󰞉%{F-}"
fi