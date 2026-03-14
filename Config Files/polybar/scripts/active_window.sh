#!/bin/bash

get_title() {
    # Redirigimos errores (2>/dev/null) para que no ensucie la salida
    ID=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $NF}')

    # Si el ID no es válido o es 0x0
    if [[ -z "$ID" || "$ID" == "0x0" ]]; then
        echo "󰇄 Desktop"
        return
    fi

    # 1. Obtener Título y Clase
    TITLE=$(xprop -id "$ID" _NET_WM_NAME 2>/dev/null | cut -d '"' -f 2)
    CLASS=$(xprop -id "$ID" WM_CLASS 2>/dev/null | awk -F '"' '{print $4}' | tr '[:upper:]' '[:lower:]')

    # Si después de intentar obtenerlos están vacíos, es que la ventana falló
    if [ -z "$TITLE" ]; then
        echo "󰇄 Desktop"
        return
    fi

    # 2. LIMPIEZA DE EMOJIS Y CARACTERES
    TITLE=$(echo "$TITLE" | sed 's/^[[:punct:][:space:]]*//; s/[^[:print:]]//g')

    # 3. LIMPIEZA ESPECÍFICA POR APP
    case "$CLASS" in
        *codium*|*code*)
            ICON="󰨞"
            CLEAN=$(echo "$TITLE" | sed -E 's/\([^\)]*\)//g; s/( — )?(VSCodium|Visual Studio Code|Untitled|Workspace|Code - OSS)//gI' | sed -E 's/[[:space:]]*[-—][[:space:]]*$//')
            [ -z "$(echo "$CLEAN" | xargs)" ] && CLEAN="Editor"
            ;;
        *firefox*|*chromium*)
            ICON="󰈹"
            CLEAN=$(echo "$TITLE" | sed -E 's/( — )?(Mozilla Firefox|Chromium)//gI' | sed -E 's/[[:space:]]*[-—][[:space:]]*$//')
            [ -z "$(echo "$CLEAN" | xargs)" ] && CLEAN="Web"
            ;;
        *alacritty*|*kitty*|*terminal*)
            ICON="󰆍"
            CLEAN=$(echo "$TITLE" | sed -E 's/(Alacritty|Kitty|Terminal)//gI')
            [ -z "$(echo "$CLEAN" | xargs)" ] && CLEAN="Term"
            ;;
        *)
            ICON="󱂬"
            CLEAN=$(echo "$TITLE" | sed -E 's/[[:space:]]*[-—][[:space:]]*$//')
            ;;
    esac

    # 4. Formateo Final y Capitalización
    CLEAN=$(echo "$CLEAN" | xargs | sed 's/ -$//; s/ —$//' | cut -c 1-25)
    
    if [ -n "$CLEAN" ]; then
        FINAL_NAME="${CLEAN,,}"
        FINAL_NAME="${FINAL_NAME^}"
        echo "${ICON} ${FINAL_NAME}"
    else
        echo "${ICON} Desktop"
    fi
}

get_title