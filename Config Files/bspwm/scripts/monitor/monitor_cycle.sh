#!/usr/bin/env bash

set -u

OVERRIDE_FILE="/tmp/monitor_override_mode"
OVERRIDE_TOPOLOGY_FILE="/tmp/monitor_override_topology"
STATE_FILE="/tmp/monitor_manual_cycle"

get_internal_monitor() {
    local m
    m=$(xrandr --query | awk '/ connected/ && $1 ~ /^(eDP|LVDS|LCD)/ {print $1; exit}')
    if [ -z "$m" ]; then
        m=$(xrandr --query | awk '/ connected/ {print $1; exit}')
    fi
    printf '%s\n' "$m"
}

get_external_monitor() {
    local internal="$1"
    xrandr --query | awk -v internal="$internal" '/ connected/ && $1 != internal {print $1; exit}'
}

INTERNAL="$(get_internal_monitor)"
EXTERNAL="$(get_external_monitor "$INTERNAL" || true)"

current="$(cat "$STATE_FILE" 2>/dev/null || echo DUAL)"

# --- 1. Caso sin monitor externo ---
if [ -z "${EXTERNAL:-}" ]; then
    next="LAPTOP_ONLY"
    echo "$next" > "$OVERRIDE_FILE"
    echo "$next" > "$STATE_FILE"
    notify-send "Monitor" "Laptop Screen Only (No HDMI)" -i display -t 2000
    exit 0
fi

# --- 2. Lógica de Ciclo ---
case "$current" in
    DUAL)
        # El manager detectará "EXTERNAL" y activará el HDMI
        next="MANUAL_EXTERNAL"
        msg="Mode: External Monitor Only"
        ;;
    MANUAL_EXTERNAL)
        # El manager detectará "LAPTOP" y activará la pantalla integrada
        next="LAPTOP_ONLY"
        msg="Mode: Laptop Screen Only"
        ;;
    *)
        next="DUAL"
        msg="Mode: Extended Display (Dual)"
        ;;
esac

# --- 3. Guardar y Notificar ---
echo "$next" > "$OVERRIDE_FILE"
echo "$next" > "$STATE_FILE"

# Forzamos una marca de tiempo en la topología para que get_state genere un nuevo MD5
date +%s > "$OVERRIDE_TOPOLOGY_FILE"

notify-send "Monitor Manager" "$msg" -i display -t 2000