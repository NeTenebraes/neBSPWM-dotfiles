#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

PRIMARY="$(xrandr --query | awk '$2 == "connected" && $3 ~ /primary/ {print $1; exit}')"
[ -z "$PRIMARY" ] && PRIMARY="$(bspc query -M --names | head -n1)"

for m in $(bspc query -M --names); do
    if [ "$m" = "$PRIMARY" ]; then
        MONITOR="$m" polybar --reload necyber-primary -c "$HOME/.config/polybar/current.ini" &
    else
        MONITOR="$m" polybar --reload necyber-secondary -c "$HOME/.config/polybar/current.ini" &
    fi
done
