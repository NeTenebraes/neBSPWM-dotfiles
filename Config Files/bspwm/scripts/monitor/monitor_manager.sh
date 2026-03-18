#!/usr/bin/env bash
# ~/.config/bspwm/scripts/monitor/monitor_manager.sh

set -u

# --- 1. Variables y Rutas ---
MONITOR_DIR="${MONITOR_DIR:-$HOME/.config/bspwm/scripts/monitor}"
STATE_FILE="/tmp/monitor_current_state"
LOCK_FILE="/tmp/monitor_setup.lock"
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/monitor_setup.log"

# --- 2. Cargar motor lógico ---
if [ -f "$MONITOR_DIR/layout_engine.sh" ]; then
    source "$MONITOR_DIR/layout_engine.sh"
else
    # Si falla el source, intentamos ruta absoluta por seguridad
    source "$HOME/.config/bspwm/scripts/monitor/layout_engine.sh"
fi

# --- 3. Prevención de Instancias Múltiples ---
exec 9>"$LOCK_FILE"
flock -n 9 || { echo "Ya hay un manager corriendo."; exit 0; }

log "=== INICIANDO MONITOR MANAGER (Modo Robusto) ==="

# Limpieza inicial para forzar la primera detección
rm -f "$STATE_FILE"
LAST_HW_FP=""

while true; do
    # Obtener huella de hardware
    CURRENT_HW_FP=$("$MONITOR_DIR/get_state.sh")

    if [ "$CURRENT_HW_FP" != "$LAST_HW_FP" ] || [ ! -f "$STATE_FILE" ]; then
        LAST_HW_FP="$CURRENT_HW_FP"
        echo "$CURRENT_HW_FP" > "$STATE_FILE"

        # Procesamiento inmediato para ganar la carrera a la suspensión
        log "Hardware change detected. processing..."

        # Detectar hardware real
        INTERNAL="$(get_internal_monitor)"
        EXTERNAL="$(get_external_monitor "$INTERNAL" || true)"
        LID_STATE="$(get_lid_state)"
        
        # Leer Overrides
        OVERRIDE_MODE="$(cat /tmp/monitor_override_mode 2>/dev/null || echo "AUTO")"
        
        # --- LÓGICA DE DECISIÓN DE MODO ---
        MODE="AUTO"
        TARGET="$INTERNAL"

        # Prioridad absoluta: Si la tapa está cerrada y hay monitor externo, forzamos Clamshell
        # Esto ignora cualquier modo manual previo para evitar la suspensión.
        if [ "$LID_STATE" = "closed" ] && [ -n "$EXTERNAL" ]; then
            log "Lid closed with external monitor. Forcing Clamshell Mode."
            MODE="CLAMSHELL"
            TARGET="$EXTERNAL"
            # Opcional: Limpiar archivos de override para que al abrir la tapa vuelva a AUTO
            rm -f /tmp/monitor_override_mode /tmp/monitor_manual_cycle
        elif [ "$OVERRIDE_MODE" = "AUTO" ]; then
            if [ -n "$EXTERNAL" ]; then
                MODE="DUAL"
            else
                MODE="LAPTOP"
                TARGET="$INTERNAL"
            fi
        else
            # Modo Manual (Ciclo)
            MODE="$OVERRIDE_MODE"
            if [[ "$MODE" == *"EXTERNAL"* ]]; then
                TARGET="${EXTERNAL:-$INTERNAL}"
            elif [[ "$MODE" == *"LAPTOP"* ]]; then
                TARGET="$INTERNAL"
            else
                TARGET="${EXTERNAL:-$INTERNAL}"
            fi
        fi

        log "Applying: $MODE | Target: $TARGET | Lid: $LID_STATE"

        # --- EJECUCIÓN ---
        case "$MODE" in
            DUAL)
                apply_dual
                ;;
            CLAMSHELL|LAPTOP|LAPTOP_ONLY|MANUAL_EXTERNAL|EXTERNAL_ONLY)
                apply_single_target "$TARGET"
                ;;
            *)
                log "Unknown mode ($MODE), forcing LAPTOP"
                apply_single_target "$INTERNAL"
                ;;
        esac

        # Refrescar UI (Polybar, Wallpapers, etc.)
        [ -x "$MONITOR_DIR/ui_refresh.sh" ] && "$MONITOR_DIR/ui_refresh.sh"
        
        log "Configuration applied successfully."
    fi

    sleep 2
done