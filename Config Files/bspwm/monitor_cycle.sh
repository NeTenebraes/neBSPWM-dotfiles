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

get_lid_state() {
    if grep -q "closed" /proc/acpi/button/lid/*/state 2>/dev/null; then
        printf 'closed\n'
    else
        printf 'open\n'
    fi
}

INTERNAL="$(get_internal_monitor)"
EXTERNAL="$(get_external_monitor "$INTERNAL" || true)"
LID_STATE="$(get_lid_state)"
TOPOLOGY_KEY="${INTERNAL}|${EXTERNAL:-none}|${LID_STATE}"

current="$(cat "$STATE_FILE" 2>/dev/null || echo DUAL)"

if [ -z "${EXTERNAL:-}" ]; then
    echo "LAPTOP_ONLY" > "$OVERRIDE_FILE"
    echo "$TOPOLOGY_KEY" > "$OVERRIDE_TOPOLOGY_FILE"
    echo "LAPTOP_ONLY" > "$STATE_FILE"
    exit 0
fi

case "$current" in
    DUAL)
        next="EXTERNAL_ONLY"
        ;;
    EXTERNAL_ONLY)
        next="LAPTOP_ONLY"
        ;;
    *)
        next="DUAL"
        ;;
esac

echo "$next" > "$OVERRIDE_FILE"
echo "$TOPOLOGY_KEY" > "$OVERRIDE_TOPOLOGY_FILE"
echo "$next" > "$STATE_FILE"
