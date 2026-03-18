#!/usr/bin/env bash
# ~/.config/bspwm/scripts/monitor/ui_refresh.sh

# Definimos el log aquí por si corres el script solo
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/monitor_setup.log"

# 1. Wallpaper (Usa la variable exportada en bspwmrc)
feh --bg-fill "${WALLPAPER}" >/dev/null 2>&1 &

# 2. Conky (Reinicio limpio usando CONKY_DIR)
killall -q conky
sleep 0.5
conky -c "${CONKY_DIR}/system.conf" >/dev/null 2>&1 &
conky -c "${CONKY_DIR}/network.conf" >/dev/null 2>&1 &
conky -c "${CONKY_DIR}/storage.conf" >/dev/null 2>&1 &

# ... (sección de conky y feh)

# 3. Polybar
log "Refrescando Polybar..."
killall -9 polybar >/dev/null 2>&1
# Esperar a que el socket de X11 se libere
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

# Lanzar Polybar (usa tu lógica de launch.sh o manual)
if [ -x "$HOME/.config/polybar/launch.sh" ]; then
    "$HOME/.config/polybar/launch.sh" >>"$LOG_FILE" 2>&1 &
else
    for m in $(xrandr --query | awk '/ connected/ {print $1}'); do
        MONITOR="$m" polybar --reload necyber -c "${POLYBAR_CONFIG}" >>"$LOG_FILE" 2>&1 &
    done
fi