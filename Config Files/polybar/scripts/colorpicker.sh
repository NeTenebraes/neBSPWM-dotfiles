#!/usr/bin/env zsh

# Configuración básica e iconos
ICON="/usr/share/icons/Papirus-Dark/128x128/apps/colorgrab.svg"

# Forzar el entorno gráfico y bus de datos para evitar fallos desde Polybar
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

case "$1" in
    --left)
        sleep 0.3
        
        # xcolor copia nativamente al portapapeles de X11
        /usr/bin/xcolor -s
        
        # Extraemos el color copiado directamente desde el portapapeles real
        HEX=$(/usr/bin/xclip -o -selection clipboard | /usr/bin/tr -d '\n')

        if [ ! -z "$HEX" ]; then
            /usr/bin/notify-send "Color Picker" "HEX: $HEX" -i "$ICON"
            sleep 0.2
        fi
        ;;

    --right)
        COL=$(/usr/bin/yad --color --title="WebColorPicker" --init-color="#ef4761" --alpha)
        
        if [ ! -z "$COL" ]; then
            # Conversión matemática de #AARRGGBB (Yad) a rgba() estándar de CSS
            RGBA=$(printf "rgba(%d,%d,%d,%.2f)" 0x${COL:3:2} 0x${COL:5:2} 0x${COL:7:2} $(( (0x${COL:1:2} * 1.0) / 255 )))
            
            echo -n "$RGBA" | /usr/bin/xclip -selection clipboard
            /usr/bin/notify-send "Web Color" "RGBA: $RGBA" -i "$ICON"
        fi
        ;;
esac