#!/usr/bin/env bash

SINK="@DEFAULT_SINK@"
MAX_VOL=150
MAX_CLICK_VOL=100
STEP=5

ICON_MUTED=""
ICON_0=""
ICON_30=""
ICON_60="󰕾"
ICON_90=""

FULL_BLOCK="█"
EMPTY_BLOCK="░"

mute="no"
vol=0

get_audio_data() {
    local data
    data="$(pactl get-sink-mute "$SINK"; pactl get-sink-volume "$SINK")"

    mute="$(awk '/^Mute:/ {print $2; exit}' <<< "$data")"
    vol="$(awk -F'/' '/Volume:/ {gsub(/[% ]/, "", $2); print $2; exit}' <<< "$data")"

    [[ "$vol" =~ ^[0-9]+$ ]] || vol=0
}

set_volume_clamped() {
    local target="$1"
    (( target < 0 )) && target=0
    (( target > MAX_VOL )) && target=$MAX_VOL
    pactl set-sink-volume "$SINK" "${target}%"
}

inc_volume() {
    get_audio_data
    pactl set-sink-mute "$SINK" 0
    set_volume_clamped $((vol + STEP))
}

dec_volume() {
    get_audio_data
    pactl set-sink-mute "$SINK" 0
    set_volume_clamped $((vol - STEP))
}

toggle_mute() {
    pactl set-sink-mute "$SINK" toggle
}

build_clickable_bar() {
    local bar="" filled i segment_vol

    if (( vol >= 100 )); then
        filled=7
    else
        filled=$(( vol * 8 / 100 ))
    fi
    (( filled > 7 )) && filled=7

    for ((i=1; i<=7; i++)); do
        segment_vol=$(( i * MAX_CLICK_VOL / 7 ))
        bar+='%{A1:~/.config/polybar/scripts/Audio.sh --set '$segment_vol' & polybar-msg action "#audio.hook.0":}'
        if [ $i -le $filled ]; then
            bar+="$FULL_BLOCK"
        else
            bar+="$EMPTY_BLOCK"
        fi
        bar+='%{A}'
    done
    printf "%s" "$bar"
}

print_status() {
    get_audio_data
    local vol_fixed icon color bar

    vol_fixed=$(printf "%3s" "$vol")

    if [[ "$mute" == "yes" || "$vol" -le 0 ]]; then
        printf '%%{F#C62828}%s [░░░░░░░] MUTE%%{F-}\n' "$ICON_MUTED"
        return
    fi

    icon=$ICON_0
    (( vol >= 30 )) && icon=$ICON_30
    (( vol >= 60 )) && icon=$ICON_60
    (( vol >= 90 )) && icon=$ICON_90

    color="#F5F5F5"
    (( vol > 100 )) && color="#FF8A65"
    (( vol > 130 )) && color="#C62828"

    bar=$(build_clickable_bar)

    # CORREGIDO: solo %%%%{F-} (dos %% para literal %)
    printf '%%{F%s}%s [%s] %s%%%%{F-}\n' "$color" "$icon" "$bar" "$vol_fixed"
}

case "${1:-}" in
    --inc) inc_volume; print_status ;;
    --dec) dec_volume; print_status ;;
    --toggle-mute) toggle_mute ;;
    --set)
        shift
        pactl set-sink-mute "$SINK" 0
        set_volume_clamped "$1"
        print_status  # Refresca después de set
        ;;
    *) print_status ;;
esac


print_status
