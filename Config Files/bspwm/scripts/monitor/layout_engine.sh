#!/usr/bin/env bash
# ~/.config/bspwm/scripts/monitor/layout_engine.sh

# 1. Variables de configuración
LEFT_DESKTOPS=(I II III IV V)
RIGHT_DESKTOPS=(VI VII VIII IX X)
STATE_FILE="/tmp/monitor_current_state"
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/monitor_setup.log"

# 2. Funciones de Utilidad y Log
log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE"
}

run_logged() {
    log "CMD: $*"
    "$@" >>"$LOG_FILE" 2>&1
    local rc=$?
    [ $rc -ne 0 ] && log "ERROR: RC=$rc"
    return $rc
}

# 3. Consultas de BSPWM
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

# 4. Consultas de XRANDR
list_all_outputs() {
    xrandr --query | awk '/ connected| disconnected/ {print $1}'
}

get_internal_monitor() {
    local m
    m=$(xrandr --query | awk '/ connected/ && $1 ~ /^(eDP|LVDS|LCD)/ {print $1; exit}')
    [ -z "$m" ] && m=$(xrandr --query | awk '/ connected/ {print $1; exit}')
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

# 5. Gestión de Nodos (Ventanas)
move_nodes_to_safe_desktop() {
    local src_id="$1"
    local target_name="$2"
    local target_id=$(first_id_by_name "$target_name")
    
    [ -z "$src_id" ] || [ -z "$target_id" ] || [ "$src_id" = "$target_id" ] && return 0
    
    # Mover todas las ventanas del ID origen al ID destino
    local node
    for node in $(bspc query -N -d "$src_id"); do
        bspc node "$node" -d "$target_id" --follow
    done
}

# 6. Sincronización de Escritorios
ensure_desktop_exists() {
    local mon="$1"
    local name="$2"
    # Si el nombre no existe en absoluto, lo creamos en el monitor
    if ! bspc query -D -d "$name" >/dev/null 2>&1; then
        bspc monitor "$mon" -a "$name"
    fi
    # Aseguramos que esté en el monitor correcto (especialmente tras Clamshell)
    bspc desktop "$name" -m "$mon"
}

sync_desktops_dual() {
    log "Sincronizando Dual (Fix 5+5)..."

    # 1. Asegurar que los 10 escritorios existan en el sistema (sin importar dónde)
    for d in "${LEFT_DESKTOPS[@]}" "${RIGHT_DESKTOPS[@]}"; do
        if ! bspc query -D --names | grep -Fxq "$d"; then
            log "Creando escritorio faltante: $d"
            # Lo creamos en el monitor externo temporalmente si el interno está naciendo
            bspc monitor "${EXTERNAL:-$INTERNAL}" -a "$d"
        fi
    done

    # 2. Forzar la ubicación de cada uno (Mover monitor)
    # Hacemos esto uno por uno para que bspwm no se confunda
    for d in "${LEFT_DESKTOPS[@]}"; do
        bspc desktop "$d" -m "$INTERNAL"
    done
    for d in "${RIGHT_DESKTOPS[@]}"; do
        bspc desktop "$d" -m "$EXTERNAL"
    done

    # 3. Limpieza de intrusos (Como el 'Desktop' que vimos en el log)
    local did name
    # Usamos un array temporal para no modificar la lista mientras la recorremos
    local to_remove=()
    while read -r did name; do
        if [[ ! " I II III IV V VI VII VIII IX X " =~ " $name " ]]; then
            to_remove+=("$did")
        fi
    done < <(all_desktop_pairs)

    for id in "${to_remove[@]}"; do
        log "Eliminando intruso ID: $id"
        # Movemos cualquier ventana que bspwm haya metido ahí al escritorio 'I'
        bspc node @$id:/ -d I
        bspc desktop "$id" -r 2>/dev/null
    done

    # 4. Ordenamiento final estricto
    bspc monitor "$INTERNAL" -o "${LEFT_DESKTOPS[@]}"
    bspc monitor "$EXTERNAL" -o "${RIGHT_DESKTOPS[@]}"
}

sync_desktops_single() {
    local target="$1"
    log "Sincronizando Single en $target"

    # 1. Asegurar los 5 principales
    for d in "${LEFT_DESKTOPS[@]}"; do ensure_desktop_exists "$target" "$d"; done

    # 2. Merge de VI-X hacia I-V antes de borrar
    local i
    for i in {0..4}; do
        local src_id=$(first_id_by_name "${RIGHT_DESKTOPS[$i]}")
        if [ -n "$src_id" ]; then
            move_nodes_to_safe_desktop "$src_id" "${LEFT_DESKTOPS[$i]}"
            bspc desktop "$src_id" -r 2>/dev/null
        fi
    done

    # 3. Limpieza total de cualquier escritorio que no sea I-V
    local did name
    while read -r did name; do
        if [[ ! " I II III IV V " =~ " $name " ]]; then
            move_nodes_to_safe_desktop "$did" "I"
            bspc desktop "$did" -r 2>/dev/null
        fi
    done < <(all_desktop_pairs)

    bspc monitor "$target" -o "${LEFT_DESKTOPS[@]}"
}

# 7. Aplicación de Estados
apply_dual() {
    log "Transición -> DUAL"
    debug_snapshot "ANTES de Xrandr"
    
    run_logged xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
    sleep 2 # Espera a que el servidor X se asiente
    
    debug_snapshot "DESPUÉS de Xrandr / ANTES de Sync"
    sync_desktops_dual
    debug_snapshot "FINAL de apply_dual"
}

apply_single_target() {
    local target="$1"
    log "Estado -> SINGLE ($target)"
    
    # 1. Xrandr: Encendemos el target y apagamos el resto
    local cmd=(xrandr --output "$target" --auto --primary)
    for out in $(list_all_outputs); do
        [ "$out" != "$target" ] && cmd+=(--output "$out" --off)
    done
    run_logged "${cmd[@]}"
    sleep 1

    # 2. BSPWM: Eliminar monitores que ya no están en xrandr ANTES de mover desktops
    # Esto evita que bspwm intente enviar comandos a un monitor muerto
    local m
    for m in $(bspc query -M --names); do
        if [ "$m" != "$target" ]; then
            # Antes de remover el monitor, movemos sus desktops al target
            for d in $(bspc query -D -m "$m"); do
                bspc desktop "$d" -m "$target"
            done
            bspc monitor "$m" -r 2>/dev/null
        fi
    done

    # 3. Sincronizar nombres y cantidad
    sync_desktops_single "$target"
    
    [ -x "$MONITOR_DIR/ui_refresh.sh" ] && "$MONITOR_DIR/ui_refresh.sh"
}

debug_snapshot() {
    local label="$1"
    {
        echo "--- DEBUG: $label ---"
        echo "Monitores XRANDR:"
        xrandr --listactivemonitors
        echo "Estado BSPWM (Monitor: Escritorios):"
        for m in $(bspc query -M --names); do
            desks=$(bspc query -D -m "$m" --names | tr '\n' ' ')
            echo "  $m: $desks"
        done
        echo "--------------------------"
    } >> "$LOG_FILE"
}