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
            # Limpiar lo más posible y obtener solo lo útil en Firefox
clean=$(printf '%s' "$title" \
    | sed -E 's/( - |- |— )?(Mozilla Firefox|Chromium|Nueva pestaña|Google|YouTube|Gmail|Spotify|Netflix|Twitter|Facebook)//Ig; s/[[:space:]]*[-—][[:space:]]*$//g; s/^[[:space:]]+|[[:space:]]+$//g'
)
# Solo el segmento anterior al primer - o —
short=$(printf '%s' "$clean" | sed -E 's/[—\-].*//')
# Unicamente la primera palabra si sigue largo
# Tomar hasta las primeras dos palabras
short=$(printf '%s' "$short" | awk '{print $1 (NF>1?" "$2:"")}')
clean=$short
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

smart_trim() {
    local input="$1"
    local maxlen="$2"
    [[ ${#input} -le $maxlen ]] && { printf "%s" "$input"; return; }
    # Corta sensatamente por palabras
    echo "$input" | awk -v max="$maxlen" '{
        l=0; out="";
        for(i=1;i<=NF;i++) {
            if (l+length($i)+(i>1?1:0)<=max) {
                out=(out?out" ":"")$i;
                l+=length($i)+(i>1?1:0);
            } else break;
        }
        print out "…"
    }'
}

final=$(smart_trim "$trimmed" 16)
final=${final,,}
final=${final^}

    printf '%s %s\n' "$icon" "$final"
}

get_title
