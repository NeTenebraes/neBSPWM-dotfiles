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

        # --- LÓGICA DE DETECCIÓN Y RESET INTELIGENTE ---
        
        # 1. Si el cable se desconecta físicamente, limpiamos rastro manual para que al re-conectar sea AUTO
        if [ -z "$EXTERNAL" ]; then
            if [ -f "/tmp/monitor_override_mode" ] || [ -f "/tmp/monitor_manual_cycle" ]; then
                log "Cable desconectado: Reseteando modos manuales para futura conexión."
                rm -f /tmp/monitor_override_mode /tmp/monitor_manual_cycle /tmp/monitor_override_topology
            fi
        fi

        # 2. Leer Overrides (si existen tras la limpieza anterior)
        OVERRIDE_MODE="$(cat /tmp/monitor_override_mode 2>/dev/null || echo "AUTO")" 
        
        # --- LÓGICA DE DECISIÓN DE MODO ---
        MODE="AUTO"
        TARGET="$INTERNAL"

# --- LÓGICA DE DECISIÓN DE MODO ---
        
        # Prioridad 1: Clamshell (Tapa cerrada + Monitor Externo)
        if [ "$LID_STATE" = "closed" ] && [ -n "$EXTERNAL" ]; then
            log "Lid closed with external monitor. Forcing Clamshell Mode."
            MODE="CLAMSHELL"
            TARGET="$EXTERNAL"
            # Limpiamos para que al abrir la tapa vuelva a modo AUTO/DUAL
            rm -f /tmp/monitor_override_mode /tmp/monitor_manual_cycle

        # Prioridad 2: Respetar Modo Manual (Ciclo) SI el monitor externo está presente
        # Solo entramos aquí si el usuario usó monitor_cycle.sh
        elif [ "$OVERRIDE_MODE" != "AUTO" ] && [ -n "$EXTERNAL" ]; then
            log "Respetando modo manual: $OVERRIDE_MODE"
            MODE="$OVERRIDE_MODE"
            if [[ "$MODE" == *"EXTERNAL"* ]]; then
                TARGET="$EXTERNAL"
            else
                TARGET="$INTERNAL"
            fi

        # Prioridad 3: Modo Automático (Dual si hay cable, Laptop si no)
        else
            if [ -n "$EXTERNAL" ]; then
                MODE="DUAL"
            else
                MODE="LAPTOP"
                TARGET="$INTERNAL"
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