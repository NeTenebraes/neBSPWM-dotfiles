#!/bin/bash

# 1. Idiomas
if [[ "$LANG" == *"es"* ]]; then
    L_TITLE="Energía"; L_CHARGE="Carga"; L_HEALTH="Salud"; L_STATUS="Estado"
    L_CHARGING="Cargando"; L_DISCHARGING="Descargando"; L_FULL="Llena"
    L_LOW_BAT="Batería Baja"; L_CRITICAL="Nivel crítico"
else
    L_TITLE="Power Info"; L_CHARGE="Charge"; L_HEALTH="Health"; L_STATUS="Status"
    L_CHARGING="Charging"; L_DISCHARGING="Discharging"; L_FULL="Full"
    L_LOW_BAT="Low Battery"; L_CRITICAL="Critical level"
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

# 4. Notificación manual (al hacer clic)
if [ "$1" = "--notify" ]; then
    health=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "capacity" | awk '{print $2}' | head -n 1)
    dunstify -u low -i "$IMG" -r 9991 "$glyph $L_TITLE" \
    "<b>$L_CHARGE:</b> $capacity%\n<b>$L_HEALTH:</b> $health\n<b>$L_STATUS:</b> $status_msg"
    exit 0
fi

# 5. Colores de salida para Polybar
if [ "$status_raw" = "Charging" ]; then
    color="#00FFFF" # Cian para carga
elif [ "$capacity" -le 20 ]; then
    color="#FF5555" # Rojo para batería crítica
elif [ "$capacity" -le 50 ]; then
    color="#FFB86C" # Naranja para batería baja
else
    color="#50FF50" # Verde para batería saludable
fi

# 6. Funciones de monitoreo automático

check_charger_status() {
    local ac_path="/sys/class/power_supply/AC"
    [[ ! -d "$ac_path" ]] && return
    
    local ac_online=$(cat "$ac_path/online" 2>/dev/null || echo "0")
    local prev_status_file="/tmp/battery_ac_status"
    local prev_status=$(cat "$prev_status_file" 2>/dev/null || echo "-1")

    if [[ "$prev_status" != "$ac_online" ]]; then
        if [[ "$ac_online" == "1" ]]; then
            local charger_msg=$([[ "$LANG" == *"es"* ]] && echo "Cargador conectado" || echo "Charger connected")
            dunstify -u normal -i "$IMG" -r 9992 "$glyph 🔌 $charger_msg" "$L_TITLE: $L_CHARGING $capacity%"
            # Resetear el nivel de notificación para que vuelva a avisar al descargar
            echo "100" > /tmp/battery_last_level
        else
            local charger_msg=$([[ "$LANG" == *"es"* ]] && echo "Cargador desconectado" || echo "Charger disconnected")
            dunstify -u normal -i "$IMG" -r 9992 "$glyph 🔌 $charger_msg" "$L_TITLE: $capacity% ($status_msg)"
        fi
        echo "$ac_online" > "$prev_status_file"
    fi
}

check_battery_levels() {
    # Solo avisar si no está cargando
    [[ "$status_raw" == "Charging" || "$status_raw" == "Full" ]] && return

    local level_file="/tmp/battery_last_level"
    local last_notified=$(cat "$level_file" 2>/dev/null || echo "100")
    
    # Umbrales: 50%, 30%, 15%, 5% (puedes cambiarlos aquí)
    for t in 50 30 15 5; do
        if [ "$capacity" -le "$t" ] && [ "$last_notified" -gt "$t" ]; then
            local urgency="normal"
            [[ $t -le 15 ]] && urgency="critical"

            dunstify -u "$urgency" -i "$IMG" -r 9993 "$glyph $L_LOW_BAT" "$L_CRITICAL: $capacity%"
            
            echo "$t" > "$level_file"
            break
        fi
    done
}

# 7. Ejecución y Salida
check_charger_status
check_battery_levels

echo "%{F$color}${T3}${glyph}${TE}%{F-}"