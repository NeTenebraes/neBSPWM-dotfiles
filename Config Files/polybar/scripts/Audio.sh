#!/usr/bin/env bash

# --- CONFIGURACIÓN ---
SINK="@DEFAULT_SINK@"
ICON_MUTED="" 
ICON_LOW=""
ICON_HIGH=""

# Definimos las barras como constantes para recortarlas (Ultra rápido)
FULL_BAR="██████████"
EMPTY_BAR="░░░░░░░░░░"

# --- OBTENCIÓN DE DATOS ---
# Usamos una sola llamada a pactl y procesamos con herramientas integradas
get_audio_data() {
    local status_raw
    status_raw=$(pactl get-sink-mute "$SINK"; pactl get-sink-volume "$SINK")
    
    # Extraemos mute y volumen usando grep con Perl-regexp (rápido y preciso)
    mute=$(echo "$status_raw" | grep -oP 'Mute: \K\w+')
    vol=$(echo "$status_raw" | grep -oP '\d+(?=%)' | head -n1)
    
    # Valor por defecto si falla la detección
    : "${vol:=0}"
}

# --- LÓGICA DE LA BARRA ---
build_bar() {
    # Calculamos cuántos bloques de 10 corresponden
    local filled=$(( vol / 10 ))
    
    # Aseguramos límites entre 0 y 10
    (( filled > 10 )) && filled=10
    (( filled < 0 )) && filled=0
    
    local empty=$(( 10 - filled ))

    # Cortamos los strings pre-definidos (Operación de memoria, no de CPU)
    bar="${FULL_BAR:0:$filled}${EMPTY_BAR:0:$empty}"
}

# --- SALIDA PARA POLYBAR ---
print_status() {
    get_audio_data

    # Estado: Silenciado
    if [ "$mute" = "yes" ] || [ "$vol" -le 0 ]; then
        echo "%{F#C62828}$ICON_MUTED  [  MUTED   ]  0%%{F-}"
        return
    fi

    # Estado: Activo
    build_bar

    # Selección de color basada en el volumen
    local color="#F5F5F5"
    if (( vol > 130 )); then
        color="#C62828"
    elif (( vol > 100 )); then
        color="#FF8A65"
    fi

    # Selección de icono
    local icon=$ICON_HIGH
    (( vol < 34 )) && icon=$ICON_LOW

    echo "%{F$color}$icon  [$bar] ${vol}%%{F-}"
}

# --- CONTROL DE ACCIONES ---
case "$1" in
    --inc) 
        pactl set-sink-mute "$SINK" 0
        pactl set-sink-volume "$SINK" +5% 
        ;;
    --dec) 
        pactl set-sink-mute "$SINK" 0
        pactl set-sink-volume "$SINK" -5% 
        ;;
    --toggle-mute) 
        pactl set-sink-mute "$SINK" toggle 
        ;;
esac

# Siempre imprimimos el resultado al final
print_status