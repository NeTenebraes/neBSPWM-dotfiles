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
        # 1. Lanzamos Yad (Formato Hexadecimal nativo)
        COL=$(/usr/bin/yad --color --title="WebColorPicker" --init-color="$INIT_COLOR" --alpha)
        
        if [ ! -z "$COL" ]; then
            HEX=$(echo "$COL" | /usr/bin/tr -d '#')

            # 2. TRADUCCIÓN MATEMÁTICA EXACTA (#RRGGBBAA)
            R_DEC=$((16#${HEX:0:2}))
            G_DEC=$((16#${HEX:2:2}))
            B_DEC=$((16#${HEX:4:2}))
            
            # Si el string tiene 8 caracteres, calculamos el Alpha flotante
            if [ ${#HEX} -eq 8 ]; then
                A_HEX=${HEX:6:2}
                A_DEC=$((16#$A_HEX))
                # Dividimos usando awk forzando el punto decimal de CSS
                ALPHA=$(LC_NUMERIC=C /usr/bin/awk "BEGIN {printf \"%.2f\", $A_DEC / 255}")
            else
                ALPHA="1.00"
            fi

            # Construimos el formato RGBA final
            RGBA="rgba($R_DEC,$G_DEC,$B_DEC,$ALPHA)"
            
            # Copiamos al portapapeles y disparamos notificación
            echo -n "$RGBA" | /usr/bin/xclip -selection clipboard
            /usr/bin/notify-send "Web Color" "Copiado RGBA a portapapeles: $RGBA" -i "$ICON"
        fi
        ;;
esac