#!/usr/bin/env bash

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-time-mode"
ICON=""

init_state() {
    mkdir -p "${STATE_FILE%/*}"
    [[ -f "$STATE_FILE" ]] || printf 'gmt\n' > "$STATE_FILE"
}

read_state() {
    IFS= read -r MODE < "$STATE_FILE" 2>/dev/null || MODE="gmt"
}

toggle_state() {
    read_state
    if [[ "$MODE" == "gmt" ]]; then
        printf 'ampm\n' > "$STATE_FILE"
    else
        printf 'gmt\n' > "$STATE_FILE"
    fi
}

print_gmt() {
    local now tz
    printf -v now '%(%b %e - )T' -1
    printf -v now '%s%s %(%H:%M:%S)T' "$now" "$ICON" -1
    printf -v tz '%(%z)T' -1

    tz="${tz%??}"                 # -0500 -> -05
    [[ "${tz:1:1}" == "0" ]] && tz="${tz:0:1}${tz:2}"   # -05 -> -5

    printf '%s [GMT%s]\n' "$now" "$tz"
}

print_ampm() {
    printf '%(%b %e - )T'"$ICON"'  %(%I:%M:%S %p)T\n' -1 -1
}

init_state

case "${1:-}" in
    --toggle)
        toggle_state
        exit 0
        ;;
esac

read_state

if [[ "$MODE" == "gmt" ]]; then
    print_gmt
else
    print_ampm
fi
