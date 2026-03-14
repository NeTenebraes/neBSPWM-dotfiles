#!/usr/bin/env bash

get_title() {
    local id title class clean icon final trimmed

    id=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $NF}')

    if [[ -z "$id" || "$id" == "0x0" ]]; then
        printf '%s\n' "󰇄 Desktop"
        return
    fi

    title=$(xprop -id "$id" _NET_WM_NAME 2>/dev/null | sed -n 's/^_NET_WM_NAME(UTF8_STRING) = "\(.*\)"$/\1/p')
    class=$(xprop -id "$id" WM_CLASS 2>/dev/null | awk -F'"' '{print tolower($4)}')

    if [[ -z "$title" ]]; then
        printf '%s\n' "󰇄 Desktop"
        return
    fi

    title=$(printf '%s' "$title" | sed 's/^[[:punct:][:space:]]*//; s/[^[:print:]]//g')

    case "$class" in
        *codium*|*code*)
            icon="󰨞"
            clean=$(printf '%s' "$title" | sed -E 's/\([^\)]*\)//g; s/( — )?(VSCodium|Visual Studio Code|Untitled|Workspace|Code - OSS)//Ig; s/[[:space:]]*[-—][[:space:]]*$//')
            ;;
        *firefox*|*chromium*)
            icon="󰈹"
            clean=$(printf '%s' "$title" | sed -E 's/( — )?(Mozilla Firefox|Chromium)//Ig; s/[[:space:]]*[-—][[:space:]]*$//')
            ;;
        *alacritty*|*kitty*|*terminal*)
            icon="󰆍"
            clean=$(printf '%s' "$title" | sed -E 's/(Alacritty|Kitty|Terminal)//Ig; s/[[:space:]]*[-—][[:space:]]*$//')
            ;;
        *)
            icon="󱂬"
            clean=$(printf '%s' "$title" | sed -E 's/[[:space:]]*[-—][[:space:]]*$//')
            ;;
    esac

    trimmed=$(printf '%s' "$clean" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
    [[ -z "$trimmed" ]] && trimmed="Desktop"

    final=$(printf '%s' "$trimmed" | cut -c 1-25)
    final=${final,,}
    final=${final^}

    printf '%s %s\n' "$icon" "$final"
}

get_title
