#!/bin/bash

# 1. Idiomas
if [[ "$LANG" == *"es"* ]]; then
    L_TITLE="Energía"; L_CHARGE="Carga"; L_HEALTH="Salud"; L_STATUS="Estado"
    L_CHARGING="Cargando"; L_DISCHARGING="Descargando"; L_FULL="Llena"
else
    L_TITLE="Power Info"; L_CHARGE="Charge"; L_HEALTH="Health"; L_STATUS="Status"
    L_CHARGING="Charging"; L_DISCHARGING="Discharging"; L_FULL="Full"
fi

# 2. Variables
BAT="/sys/class/power_supply/BAT0"
PATH_PAPI="/usr/share/icons/Papirus-Dark/48x48/status"
capacity=$(cat "$BAT/capacity" 2>/dev/null || echo "0")
status_raw=$(cat "$BAT/status" 2>/dev/null || echo "Discharging")

# Tags de fuente para Polybar
T3="%{T3}"
TE="%{T-}"

# 3. Lógica de Iconos
if [ "$status_raw" = "Charging" ]; then
    status_msg=$L_CHARGING
    if   [ "$capacity" -le 20 ]; then glyph="󰢜"; IMG="$PATH_PAPI/battery-caution-charging.svg"
    elif [ "$capacity" -le 40 ]; then glyph="󰂇"; IMG="$PATH_PAPI/battery-low-charging.svg"
    elif [ "$capacity" -le 60 ]; then glyph="󰂉"; IMG="$PATH_PAPI/battery-good-charging.svg"
    elif [ "$capacity" -le 80 ]; then glyph="󰂊"; IMG="$PATH_PAPI/battery-good-charging.svg"
    else                           glyph="󰂅"; IMG="$PATH_PAPI/battery-full-charging.svg"
    fi
elif [ "$status_raw" = "Full" ]; then
    status_msg=$L_FULL; glyph="󰁹"; IMG="$PATH_PAPI/battery-full-charged.svg"
else
    status_msg=$L_DISCHARGING
    if   [ "$capacity" -le 10 ]; then glyph="󰁺"; IMG="$PATH_PAPI/battery-caution.svg"
    elif [ "$capacity" -le 20 ]; then glyph="󰁻"; IMG="$PATH_PAPI/battery-caution.svg"
    elif [ "$capacity" -le 30 ]; then glyph="󰁼"; IMG="$PATH_PAPI/battery-low.svg"
    elif [ "$capacity" -le 40 ]; then glyph="󰁽"; IMG="$PATH_PAPI/battery-low.svg"
    elif [ "$capacity" -le 50 ]; then glyph="󰁾"; IMG="$PATH_PAPI/battery-good.svg"
    elif [ "$capacity" -le 60 ]; then glyph="󰁿"; IMG="$PATH_PAPI/battery-good.svg"
    elif [ "$capacity" -le 70 ]; then glyph="󰂀"; IMG="$PATH_PAPI/battery-good.svg"
    elif [ "$capacity" -le 80 ]; then glyph="󰂁"; IMG="$PATH_PAPI/battery-good.svg"
    elif [ "$capacity" -le 90 ]; then glyph="󰂂"; IMG="$PATH_PAPI/battery-full.svg"
    else                           glyph="󰁹"; IMG="$PATH_PAPI/battery-full.svg"
    fi
fi

# 4. Notificación
if [ "$1" = "--notify" ]; then
    health=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "capacity" | awk '{print $2}' | head -n 1)
    dunstify -u low -i "$IMG" -r 9991 "$glyph $L_TITLE" \
    "<b>$L_CHARGE:</b> $capacity%\n<b>$L_HEALTH:</b> $health\n<b>$L_STATUS:</b> $status_msg"
    exit 0
fi

# 5. Salida para Polybar
if [ "$status_raw" = "Charging" ]; then
    color="#00FFFF" # Cian para carga
elif [ "$capacity" -le 30 ]; then
    color="#FF5555" # Rojo para batería crítica
elif [ "$capacity" -le 60 ]; then
    color="#FFB86C" # Naranja para batería baja
else
    color="#50FF50" # Verde para batería saludable
fi

# Imprimimos 
echo "%{F$color}${T3}${glyph}${TE}%{F-}"