#!/usr/bin/env bash

SINK="@DEFAULT_SINK@"
# Iconos para: Mudo, 0-30%, 31-60%, 61-90%, >90%
ICON_MUTED="" 
ICON_0=""
ICON_30=""
ICON_60="󰕾"
ICON_90=""

FULL_BAR="███████"
EMPTY_BAR="░░░░░░░"

get_audio_data() {
    local status_raw=$(pactl get-sink-mute "$SINK"; pactl get-sink-volume "$SINK")
    mute=$(echo "$status_raw" | grep -oP 'Mute: \K\w+')
    vol=$(echo "$status_raw" | grep -oP '\d+(?=%)' | head -n1)
    : "${vol:=0}"
}

build_bar() {
    local filled=$(( vol * 7 / 100 ))
    (( filled > 7 )) && filled=7
    (( filled < 0 )) && filled=0
    bar="${FULL_BAR:0:$filled}${EMPTY_BAR:0:$((7 - filled))}"
}

print_status() {
    get_audio_data
    local vol_fixed=$(printf "%3s" "$vol")

    if [ "$mute" = "yes" ] || [ "$vol" -le 0 ]; then
        echo "%{F#C62828}$ICON_MUTED  [  MUTED   ]   0%%{F-}"
    else
        build_bar
        # Lógica de Iconos por rangos
        local icon=$ICON_0
        (( vol >= 30 )) && icon=$ICON_30
        (( vol >= 60 )) && icon=$ICON_60
        (( vol >= 90 )) && icon=$ICON_90

        # Lógica de Colores
        local color="#F5F5F5"
        (( vol > 130 )) && color="#C62828" || { (( vol > 100 )) && color="#FF8A65"; }

        echo "%{F$color}$icon  [$bar] ${vol_fixed}%%{F-}"
    fi
}

case "$1" in
    --inc) pactl set-sink-mute "$SINK" 0; pactl set-sink-volume "$SINK" +5% ;;
    --dec) pactl set-sink-mute "$SINK" 0; pactl set-sink-volume "$SINK" -5% ;;
    --toggle-mute) pactl set-sink-mute "$SINK" toggle ;;
esac

print_status
