#!/bin/bash

# Colores
WHITE="%{F#FFFFFF}"
GREEN="%{F#44FF44}"
RED="%{F#FF4444}"
CYAN="%{F#00FFFF}"
GRAY="%{F#777777}"
RESET="%{F-}"

check_firewall() {
    systemctl is-active --quiet ufw || systemctl is-active --quiet firewalld || systemctl is-active --quiet nftables
}

# Alternancia cada 5 segundos
rem=$(( $(date +%s) % 10 ))

if [ $rem -lt 5 ]; then
    # --- MODO FIREWALL ---
    # Usamos "FW:  ON" (2 espacios) y "FW: OFF" para que ambos midan 6 caracteres
    if check_firewall; then
        icon="${GREEN}󰒘${RESET}"
        status="${WHITE}FW:  ON${RESET}"
    else
        icon="${RED}󰦝${RESET}"
        status="${WHITE}FW: OFF${RESET}"
    fi
else
    # --- MODO VPN ---
    vpn_iface=$(ip addr | grep -E 'tun[0-9]|ppp[0-9]|wg[0-9]' | awk -F: '{print $2}' | tr -d ' ' | head -1)
    if [ -n "$vpn_iface" ]; then
        icon="${CYAN}󰞉${RESET}"
        status="${WHITE}VPN: ON${RESET}"
    else
        icon="${GRAY}󰞉${RESET}"
        status="${WHITE}VPN:OFF${RESET}"
    fi
fi

# El formato final siempre tendrá el mismo ancho
echo "${icon} ${status}"