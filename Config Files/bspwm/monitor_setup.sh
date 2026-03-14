#!/usr/bin/env bash

set -u

WALLPAPER="$HOME/.config/bspwm/wallpaper.png"
STATE_FILE="/tmp/monitor_current_state"
LOCK_FILE="/tmp/monitor_setup.lock"
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/monitor_setup.log"

LEFT_DESKTOPS=(I II III IV V)
RIGHT_DESKTOPS=(VI VII VIII IX X)

mkdir -p "$(dirname "$LOG_FILE")"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE"
}

restart_conky() {
    killall -q conky
    sleep 0.5
    conky -c "$HOME/.config/conky/system_top.conf" >/dev/null 2>&1 &
    conky -c "$HOME/.config/conky/network_bottom.conf" >/dev/null 2>&1 &
}

run_logged() {
    log "CMD: $*"
    "$@" >>"$LOG_FILE" 2>&1
    local rc=$?
    log "RC=$rc"
    return $rc
}

wait_for_bspwm_monitor() {
    local mon="$1"
    local i

    for i in $(seq 1 20); do
        if monitor_exists "$mon"; then
            return 0
        fi
        sleep 0.2
    done

    return 1
}

snapshot() {
    {
        echo "----- SNAPSHOT $(date '+%F %T') -----"
        echo "STATE_FILE=$(cat "$STATE_FILE" 2>/dev/null || echo '<empty>')"
        echo "XRANDR_HEAD:"
        xrandr --query | head -n 12
        echo
        echo "XRANDR_LISTMONITORS:"
        xrandr --listmonitors 2>&1
        echo
        echo "XDPYINFO_DIMENSIONS:"
        xdpyinfo | grep dimensions 2>&1
        echo
        echo "BSPWM_MONITORS:"
        bspc query -M --names 2>&1
        echo
        echo "BSPWM_DESKTOPS:"
        bspc query -D --names 2>&1
        echo "----- END SNAPSHOT -----"
        echo
    } >>"$LOG_FILE" 2>&1
}

all_desktop_pairs() {
    paste <(bspc query -D 2>/dev/null) <(bspc query -D --names 2>/dev/null)
}

ids_by_name() {
    local name="$1"
    all_desktop_pairs | awk -v n="$name" '$2 == n {print $1}'
}

first_id_by_name() {
    ids_by_name "$1" | head -n1
}

monitor_exists() {
    bspc query -M --names 2>/dev/null | grep -Fxq "$1"
}

monitor_of_desktop_id() {
    local did="$1"
    local mon
    for mon in $(bspc query -M --names 2>/dev/null); do
        if bspc query -D -m "$mon" 2>/dev/null | grep -Fxq "$did"; then
            printf '%s\n' "$mon"
            return 0
        fi
    done
    return 1
}

bspwm_monitor_count() {
    local n
    n="$(bspc query -M --names 2>/dev/null | wc -l)"
    n="${n// /}"
    printf '%s\n' "${n:-0}"
}

xrandr_monitor_count() {
    xrandr --listmonitors 2>/dev/null | awk 'NR==1 {print $2}'
}

list_all_outputs() {
    xrandr --query | awk '/ connected| disconnected/ {print $1}'
}

get_internal_monitor() {
    local m
    m=$(xrandr --query | awk '/ connected/ && $1 ~ /^(eDP|LVDS|LCD)/ {print $1; exit}')
    if [ -z "$m" ]; then
        m=$(xrandr --query | awk '/ connected/ {print $1; exit}')
    fi
    printf '%s\n' "$m"
}

get_external_monitor() {
    local internal="$1"
    xrandr --query | awk -v internal="$internal" '/ connected/ && $1 != internal {print $1; exit}'
}

get_lid_state() {
    if grep -q "closed" /proc/acpi/button/lid/*/state 2>/dev/null; then
        printf 'closed\n'
    else
        printf 'open\n'
    fi
}

get_output_geometry() {
    local mon="$1"

    xrandr --query | awk -v mon="$mon" '
        $1 == mon && $2 == "connected" {
            for (i = 3; i <= NF; i++) {
                if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
                    print $i
                    exit
                }
            }
        }
    '
}

get_output_size() {
    local mon="$1"
    local geom width height

    geom="$(get_output_geometry "$mon")"
    [ -n "$geom" ] || return 1

    width="${geom%%x*}"
    height="${geom#*x}"
    height="${height%%+*}"

    printf '%sx%s\n' "$width" "$height"
}

get_output_mode() {
    local mon="$1"

    xrandr --query | awk -v mon="$mon" '
        $1 == mon && $2 == "connected" { inout=1; next }
        inout && $2 ~ /connected|disconnected/ { exit }
        inout && $1 ~ /^[0-9]+x[0-9]+$/ {
            if (!first) first=$1
            if ($2 ~ /\*/) { print $1; exit }
        }
        END {
            if (first) print first
        }
    '
}

get_output_size_or_mode() {
    local mon="$1"
    get_output_size "$mon" 2>/dev/null || get_output_mode "$mon"
}

screen_current_size() {
    xrandr --query | awk '
        /^Screen 0:/ {
            for (i = 1; i <= NF; i++) {
                if ($i == "current") {
                    w = $(i+1)
                    h = $(i+3)
                    gsub(",", "", w)
                    gsub(",", "", h)
                    print w "x" h
                    exit
                }
            }
        }
    '
}

get_output_x() {
    local mon="$1"
    local geom x

    geom="$(get_output_geometry "$mon")"
    [ -n "$geom" ] || return 1

    x="${geom#*+}"
    x="${x%%+*}"
    printf '%s\n' "$x"
}

needs_dual_repair() {
    local int_size ext_size
    local int_w int_h ext_w ext_h
    local ext_x current xrmons bspmons
    local fb_w fb_h expected_fb

    [ -n "${EXTERNAL:-}" ] || return 1

    int_size="$(get_output_size_or_mode "$INTERNAL" 2>/dev/null || true)"
    ext_size="$(get_output_size_or_mode "$EXTERNAL" 2>/dev/null || true)"
    [ -n "$int_size" ] || return 1
    [ -n "$ext_size" ] || return 1

    int_w="${int_size%x*}"
    int_h="${int_size#*x}"
    ext_w="${ext_size%x*}"
    ext_h="${ext_size#*x}"

    ext_x="$(get_output_x "$EXTERNAL" 2>/dev/null || echo -1)"
    current="$(screen_current_size 2>/dev/null || true)"
    xrmons="$(xrandr_monitor_count 2>/dev/null || echo 0)"
    bspmons="$(bspwm_monitor_count 2>/dev/null || echo 0)"

    fb_w=$((int_w + ext_w))
    if [ "$int_h" -gt "$ext_h" ]; then
        fb_h="$int_h"
    else
        fb_h="$ext_h"
    fi
    expected_fb="${fb_w}x${fb_h}"

    log "needs_dual_repair int=${int_w}x${int_h} ext=${ext_w}x${ext_h} ext_x=${ext_x} expected_x=${int_w} current='${current}' expected_fb='${expected_fb}' xrmons=${xrmons} bspmons=${bspmons}"

    [ "$ext_x" != "$int_w" ] && return 0
    [ "$current" != "$expected_fb" ] && return 0
    [ "${xrmons:-0}" -ne 2 ] && return 0
    [ "${bspmons:-0}" -ne 2 ] && return 0

    return 1
}

wait_ready() {
    local i
    for i in $(seq 1 20); do
        if xrandr --query >/dev/null 2>&1 && bspc query -M >/dev/null 2>&1; then
            break
        fi
        sleep 0.2
    done
    sleep 1
}

move_nodes_desktop_to_desktop() {
    local src="$1"
    local dst="$2"
    local node

    [ -n "$src" ] || return 0
    [ -n "$dst" ] || return 0
    [ "$src" = "$dst" ] && return 0

    while read -r node; do
        [ -n "$node" ] && bspc node "$node" -d "$dst" 2>/dev/null || true
    done < <(bspc query -N -d "$src" 2>/dev/null)
}

ensure_unique_desktop() {
    local target_mon="$1"
    local name="$2"
    local keep=""
    local extra=""

    monitor_exists "$target_mon" || return 0

    keep="$(first_id_by_name "$name")"
    if [ -z "$keep" ]; then
        bspc monitor "$target_mon" -a "$name"
        keep="$(first_id_by_name "$name")"
        log "Creado desktop '$name' en '$target_mon' -> id=$keep"
    fi

    [ -n "$keep" ] && bspc desktop "$keep" -m "$target_mon" 2>/dev/null || true

    while read -r extra; do
        [ -n "$extra" ] || continue
        [ "$extra" = "$keep" ] && continue
        log "Fusionando duplicado desktop '$name': $extra -> $keep"
        move_nodes_desktop_to_desktop "$extra" "$keep"
        bspc desktop "$extra" -r 2>/dev/null || true
    done < <(ids_by_name "$name")
}

merge_name_into_name() {
    local src_name="$1"
    local dst_name="$2"
    local dst_id=""
    local src_id=""

    dst_id="$(first_id_by_name "$dst_name")"
    [ -n "$dst_id" ] || return 0

    while read -r src_id; do
        [ -n "$src_id" ] || continue
        [ "$src_id" = "$dst_id" ] && continue
        log "Moviendo nodos $src_name($src_id) -> $dst_name($dst_id)"
        move_nodes_desktop_to_desktop "$src_id" "$dst_id"
        bspc desktop "$src_id" -r 2>/dev/null || true
    done < <(ids_by_name "$src_name")
}

cleanup_unwanted_dual() {
    local did name mon target

    while read -r did name; do
        [ -n "$did" ] || continue

        case "$name" in
            I|II|III|IV|V|VI|VII|VIII|IX|X) continue ;;
        esac

        mon="$(monitor_of_desktop_id "$did")"
        if [ "$mon" = "$EXTERNAL" ]; then
            target="$(first_id_by_name VI)"
        else
            target="$(first_id_by_name I)"
        fi

        log "Eliminando desktop no deseado '$name' ($did), moviendo a $target"
        move_nodes_desktop_to_desktop "$did" "$target"
        bspc desktop "$did" -r 2>/dev/null || true
    done < <(all_desktop_pairs)
}

sync_desktops_strict() {
    local m d did

    # Asegurar que existan exactamente dos monitores
    if [ "$(bspwm_monitor_count)" -ne 2 ]; then
        log "sync_desktops_strict: no hay exactamente 2 monitores, omito"
        return 0
    fi

    # Asegurar que existan todos los nombres I..X
    for d in "${LEFT_DESKTOPS[@]}" "${RIGHT_DESKTOPS[@]}"; do
        if ! ids_by_name "$d" >/dev/null 2>&1; then
            bspc monitor eDP -a "$d"
            log "sync_desktops_strict: creado desktop faltante '$d'"
        fi
    done

    # Desasignar cualquier desktop extra que no sea I..X
    cleanup_unwanted_dual

    # Forzar que I..V estén en INTERNAL y VI..X en EXTERNAL
    for d in "${LEFT_DESKTOPS[@]}"; do
        did="$(first_id_by_name "$d")"
        [ -n "$did" ] && bspc desktop "$did" -m "$INTERNAL" 2>/dev/null || true
    done

    for d in "${RIGHT_DESKTOPS[@]}"; do
        did="$(first_id_by_name "$d")"
        [ -n "$did" ] && bspc desktop "$did" -m "$EXTERNAL" 2>/dev/null || true
    done

    # Orden en cada monitor
    reorder_monitor "$INTERNAL" "${LEFT_DESKTOPS[@]}"
    reorder_monitor "$EXTERNAL" "${RIGHT_DESKTOPS[@]}"

    log "sync_desktops_strict: INTERNAL=${LEFT_DESKTOPS[*]} EXTERNAL=${RIGHT_DESKTOPS[*]}"
}

sync_single_monitor() {
    local target="$1"
    local i d m

    log "sync_single_monitor: target=$target"

    # 1) Mover/crear I..V en el monitor activo
    for d in "${LEFT_DESKTOPS[@]}"; do
        if [ -z "$(first_id_by_name "$d")" ]; then
            bspc monitor "$target" -a "$d" 2>/dev/null || true
            log "sync_single_monitor: creado '$d' en $target"
        fi

        did="$(first_id_by_name "$d")"
        [ -n "$did" ] && bspc desktop "$did" -m "$target" 2>/dev/null || true
    done

    # 2) Fusionar VI..X dentro de I..V
    for i in "${!RIGHT_DESKTOPS[@]}"; do
        merge_name_into_name "${RIGHT_DESKTOPS[$i]}" "${LEFT_DESKTOPS[$i]}"
    done

    # 3) Limpiar cualquier nombre raro
    cleanup_unwanted_single

    # 4) Quitar los otros monitores BSPWM solo después de mover los desktops
    for m in $(bspc query -M --names 2>/dev/null); do
        [ "$m" = "$target" ] && continue
        bspc monitor "$m" -r 2>/dev/null || true
    done

    # 5) Segunda pasada de seguridad
    for d in "${LEFT_DESKTOPS[@]}"; do
        ensure_unique_desktop "$target" "$d"
    done

    reorder_monitor "$target" "${LEFT_DESKTOPS[@]}"
    bspc desktop "$(first_id_by_name I)" -f 2>/dev/null || true

    log "sync_single_monitor final desktops: $(bspc query -D --names 2>/dev/null | tr '\n' ' ')"
}



cleanup_unwanted_single() {
    local did name target

    target="$(first_id_by_name I)"

    while read -r did name; do
        [ -n "$did" ] || continue

        case "$name" in
            I|II|III|IV|V) continue ;;
        esac

        log "Eliminando desktop no deseado '$name' ($did), moviendo a $target"
        move_nodes_desktop_to_desktop "$did" "$target"
        bspc desktop "$did" -r 2>/dev/null || true
    done < <(all_desktop_pairs)
}

reorder_monitor() {
    local mon="$1"
    shift
    monitor_exists "$mon" || return 0
    bspc monitor "$mon" -o "$@" 2>/dev/null || true
}

restart_polybar() {
    killall -q polybar
    while pgrep -u "$UID" -x polybar >/dev/null; do
        sleep 0.2
    done

    if [ -x "$HOME/.config/polybar/launch.sh" ]; then
        "$HOME/.config/polybar/launch.sh" >>"$LOG_FILE" 2>&1 &
    else
        local m
        for m in $(xrandr --query | awk '/ connected/ {print $1}'); do
            MONITOR="$m" polybar --reload necyber -c "$HOME/.config/polybar/current.ini" >>"$LOG_FILE" 2>&1 &
        done
    fi
}

refresh_ui() {
    feh --bg-fill "$WALLPAPER" >/dev/null 2>&1 &
    sleep 1
    restart_conky
    restart_polybar
}

needs_single_repair() {
    local target="$1"
    local expected current xrmons bspmons

    expected="$(get_output_size_or_mode "$target" 2>/dev/null || true)"
    current="$(screen_current_size 2>/dev/null || true)"
    xrmons="$(xrandr_monitor_count 2>/dev/null || echo 0)"
    bspmons="$(bspwm_monitor_count 2>/dev/null || echo 0)"

    log "needs_single_repair target=$target expected='${expected:-}' current='${current:-}' xrmons='${xrmons:-0}' bspmons='${bspmons:-0}'"

    [ -z "${expected:-}" ] && return 1

    if [ "$current" != "$expected" ]; then
        return 0
    fi

    if [ "${xrmons:-0}" -ne 1 ]; then
        return 0
    fi

    if [ "${bspmons:-0}" -ne 1 ]; then
        return 0
    fi

    return 1
}

apply_dual() {
    local d
    local int_size ext_size
    local int_w int_h ext_w ext_h fb_w fb_h

    log "apply_dual start INTERNAL=$INTERNAL EXTERNAL=$EXTERNAL BSP_MONS=$(bspwm_monitor_count) XR_MONS=$(xrandr_monitor_count 2>/dev/null || echo 0)"
    snapshot

    int_size="$(get_output_size_or_mode "$INTERNAL")" || {
        log "No pude resolver tamaño/modo de $INTERNAL"
        xrandr --query >>"$LOG_FILE" 2>&1
        return 1
    }

    ext_size="$(get_output_size_or_mode "$EXTERNAL")" || {
        log "No pude resolver tamaño/modo de $EXTERNAL"
        xrandr --query >>"$LOG_FILE" 2>&1
        return 1
    }

    int_w="${int_size%x*}"
    int_h="${int_size#*x}"
    ext_w="${ext_size%x*}"
    ext_h="${ext_size#*x}"

    fb_w=$((int_w + ext_w))
    if [ "$int_h" -gt "$ext_h" ]; then
        fb_h="$int_h"
    else
        fb_h="$ext_h"
    fi

    log "apply_dual INTERNAL=$INTERNAL EXTERNAL=$EXTERNAL int=${int_w}x${int_h} ext=${ext_w}x${ext_h} fb=${fb_w}x${fb_h}"

    run_logged xrandr \
        --output "$EXTERNAL" --off \
        --output "$INTERNAL" --mode "${int_w}x${int_h}" --pos 0x0 --primary --rotate normal --panning 0x0 \
        --fb "${int_w}x${int_h}" || return 1

    sleep 1

    run_logged xrandr \
        --output "$INTERNAL" --mode "${int_w}x${int_h}" --pos 0x0 --primary --rotate normal --panning 0x0 \
        --output "$EXTERNAL" --mode "${ext_w}x${ext_h}" --pos "${int_w}x0" --rotate normal --panning 0x0 \
        --fb "${fb_w}x${fb_h}" || return 1

    sleep 2

    if [ "$(bspwm_monitor_count)" -lt 2 ]; then
        log "BSPWM sigue viendo un solo monitor; forzando recarga"
        bspc wm -r
        sleep 1
    fi

    wait_for_bspwm_monitor "$EXTERNAL" || true

    if needs_dual_repair; then
        log "Reintentando reparación dual"

        run_logged xrandr \
            --output "$EXTERNAL" --off \
            --output "$INTERNAL" --mode "${int_w}x${int_h}" --pos 0x0 --primary --rotate normal --panning 0x0 \
            --fb "${int_w}x${int_h}" || return 1

        sleep 1

        run_logged xrandr \
            --output "$INTERNAL" --mode "${int_w}x${int_h}" --pos 0x0 --primary --rotate normal --panning 0x0 \
            --output "$EXTERNAL" --mode "${ext_w}x${ext_h}" --pos "${int_w}x0" --rotate normal --panning 0x0 \
            --fb "${fb_w}x${fb_h}" || return 1

        sleep 2

        if [ "$(bspwm_monitor_count)" -lt 2 ]; then
            log "Segunda recarga de BSPWM tras reparación dual"
            bspc wm -r
            sleep 1
        fi

        wait_for_bspwm_monitor "$EXTERNAL" || true
    fi

    for d in "${LEFT_DESKTOPS[@]}"; do
        ensure_unique_desktop "$INTERNAL" "$d"
    done

    for d in "${RIGHT_DESKTOPS[@]}"; do
        ensure_unique_desktop "$EXTERNAL" "$d"
    done

    cleanup_unwanted_dual

    bspc wm -O "$INTERNAL" "$EXTERNAL" 2>/dev/null || true
    reorder_monitor "$INTERNAL" "${LEFT_DESKTOPS[@]}"
    reorder_monitor "$EXTERNAL" "${RIGHT_DESKTOPS[@]}"

    for d in "${RIGHT_DESKTOPS[@]}"; do
        ensure_unique_desktop "$EXTERNAL" "$d"
    done
    reorder_monitor "$EXTERNAL" "${RIGHT_DESKTOPS[@]}"

    bspc desktop "$(first_id_by_name I)" -f 2>/dev/null || true
    sync_desktops_strict
    snapshot

}

apply_single_target() {
    local target="$1"
    local size width height
    local cmd=()
    local out

    size="$(get_output_size_or_mode "$target")" || return 1
    width="${size%x*}"
    height="${size#*x}"

    log "apply_single_target target=$target size=${width}x${height}"
    snapshot

    cmd=(xrandr
        --output "$target" --mode "${width}x${height}" --pos 0x0 --primary --rotate normal
        --panning "${width}x${height}+0+0/${width}x${height}+0+0/0/0/0/0"
    )

    for out in $(list_all_outputs); do
        [ "$out" = "$target" ] && continue
        cmd+=(--output "$out" --off)
    done

    cmd+=(--fb "${width}x${height}")

    run_logged "${cmd[@]}" || return 1
    sleep 1

    if needs_single_repair "$target"; then
        log "Reintentando reparación single"
        run_logged "${cmd[@]}" || return 1
        sleep 1
    fi

    sync_single_monitor "$target"
    snapshot
}

wait_ready
rm -f "$STATE_FILE"
: > "$LOG_FILE"

log "Monitor Manager iniciado. PID=$$"
snapshot

while true; do
    INTERNAL="$(get_internal_monitor)"
    EXTERNAL="$(get_external_monitor "$INTERNAL" || true)"
    LID_STATE="$(get_lid_state)"
    BSP_MONS="$(bspwm_monitor_count)"
    XR_MONS="$(xrandr_monitor_count 2>/dev/null || echo 0)"

    if [ -n "${EXTERNAL:-}" ] && [ "$LID_STATE" = "closed" ]; then
        MODE="CLAMSHELL"
        TARGET="$EXTERNAL"
        CURRENT_STATE="$MODE:$TARGET"
    elif [ -n "${EXTERNAL:-}" ]; then
        MODE="DUAL"
        TARGET=""
        CURRENT_STATE="$MODE:$INTERNAL:$EXTERNAL"
    else
        MODE="LAPTOP"
        TARGET="$INTERNAL"
        CURRENT_STATE="$MODE:$TARGET"
    fi

    LAST_STATE="$(cat "$STATE_FILE" 2>/dev/null || true)"

    log "loop INTERNAL=$INTERNAL EXTERNAL='${EXTERNAL:-}' LID=$LID_STATE BSP_MONS=$BSP_MONS XR_MONS=$XR_MONS MODE=$MODE CURRENT='$CURRENT_STATE' LAST='$LAST_STATE'"

    need_apply=0

    if [ "$CURRENT_STATE" != "$LAST_STATE" ] || ! pgrep -x polybar >/dev/null; then
        need_apply=1
    fi

    if [ "$MODE" = "LAPTOP" ] && needs_single_repair "$TARGET"; then
        need_apply=1
    fi

    if [ "$MODE" = "CLAMSHELL" ] && needs_single_repair "$TARGET"; then
        need_apply=1
    fi

    if [ "$MODE" = "DUAL" ] && needs_dual_repair; then
        need_apply=1
    fi

    if [ "$need_apply" -eq 1 ]; then
        log "Aplicando transición de estado"

        ok=0
        case "$MODE" in
            DUAL) apply_dual || ok=1 ;;
            CLAMSHELL) apply_single_target "$TARGET" || ok=1 ;;
            LAPTOP) apply_single_target "$TARGET" || ok=1 ;;
        esac

        if [ "$ok" -eq 0 ]; then
            printf '%s\n' "$CURRENT_STATE" > "$STATE_FILE"
            refresh_ui
            log "Transición terminada"
        else
            log "Transición falló; NO actualizo STATE_FILE"
        fi
    fi

    sleep 2
done
