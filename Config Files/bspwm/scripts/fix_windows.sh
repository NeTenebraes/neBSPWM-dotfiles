#!/usr/bin/env bash
set -u

# ==============================================================================
# NOTAS DE USO Y OPCIONES POSIBLES (FORMATO DE REGLAS)
# ==============================================================================
# El formato es: 'CLASS|NAME|WIDTH|HEIGHT|STATE|STICKY|DELAY|ACTION'
#
# 1. CLASS:  Clase de la ventana (WM_CLASS).
# 2. NAME:   Nombre de la ventana (WM_NAME). Usa "*" para cualquier nombre.
# 3. WIDTH:  Ancho en píxeles (solo se usa si ACTION es "center").
# 4. HEIGHT: Alto en píxeles (solo se usa si ACTION es "center").
# 5. STATE:  Estado de bspwm. Opciones: [tiled, floating, fullscreen, pseudo_tiled]
#            DEJAR VACÍO para no alterar el estado actual de la ventana.
# 6. STICKY: Opciones: [on, off]. Mantiene la ventana en todos los escritorios.
# 7. DELAY:  Tiempo de espera (segundos) antes de actuar. Útil para Java/Electron.
# 8. ACTION: Define el comportamiento del script:
#    - center:       Redimensiona la ventana a WIDTHxHEIGHT y la pone al centro.
#    - float_center: NO redimensiona. Detecta el tamaño de la ventana y la centra.
#    - apply_props:  Solo aplica STATE y STICKY. No mueve ni redimensiona.
#    - skip:         Ignora la ventana por completo.
# ==============================================================================

RULES=(
#  Formato: 'CLASS|NAME|WIDTH|HEIGHT|STATE|STICKY|DELAY|ACTION'

  'MEGAsync|Add sync|700|520|floating|off|0.35|center'
  'Nemo|File conflict|0|0|floating|off|0.01|float_center'
  
  # --- ESTRATEGIA PARA RUNELITE ---
  # 1. Cliente principal
  'net-runelite-client-RuneLite|RuneLite|0|0||off|0.1|skip'
  
  # 2. Todo lo demás de RuneLite: Forzar floating y centrar sin cambiar tamaño
  'net-runelite-client-RuneLite|*|0|0|floating|off|0.01|float_center'
)

LOCK_DIR="/tmp/fix_windows_locks"
mkdir -p "$LOCK_DIR"

# --- FUNCIONES AUXILIARES ---

get_props() {
  local wid="$1"
  xprop -id "$wid" WM_CLASS WM_NAME _NET_WM_NAME 2>/dev/null || true
}

extract_class() {
  sed -n 's/.*WM_CLASS(STRING) = "[^"]*", "\(.*\)"/\1/p' | head -n1
}

extract_name() {
  local name
  name="$(sed -n 's/_NET_WM_NAME(UTF8_STRING) = "\(.*\)"/\1/p' | head -n1)"
  [[ -z "$name" ]] && name="$(sed -n 's/WM_NAME(STRING) = "\(.*\)"/\1/p' | head -n1)"
  printf '%s\n' "$name"
}

get_output_geometry() {
  local mon="$1"
  xrandr --query | awk -v mon="$mon" '
    $1 == mon && $2 == "connected" {
      for (i = 3; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
          print $i; exit
        }
      }
    }
  '
}

get_monitor_name_by_id() {
  local mid="$1"
  bspc query -M --names | while read -r mon; do
    [[ "$(bspc query -M -m "$mon" | head -n1)" == "$mid" ]] && { printf '%s\n' "$mon"; return 0; }
  done
}

# --- POSICIONAMIENTO ---

center_window_on_monitor() {
  local wid="$1" mon="$2" w="$3" h="$4"
  local geom mw mh mx my x y
  geom="$(get_output_geometry "$mon")"
  [[ -z "$geom" ]] && return 1
  mw="${geom%%x*}"; mh="${geom#*x}"; mh="${mh%%+*}"
  mx="${geom#*+}"; mx="${mx%%+*}"; my="${geom##*+}"
  
  x=$(( mx + (mw - w) / 2 ))
  y=$(( my + (mh - h) / 2 ))

  # Cambiamos tamaño y movemos
  xdotool windowsize --sync "$wid" "$w" "$h"
  xdotool windowmove --sync "$wid" "$x" "$y"
}

center_current_size_on_monitor() {
  local wid="$1" mon="$2"
  local geom mw mh mx my WIDTH HEIGHT x y out
  geom="$(get_output_geometry "$mon")"
  [[ -z "$geom" ]] && return 1
  mw="${geom%%x*}"; mh="${geom#*x}"; mh="${mh%%+*}"
  mx="${geom#*+}"; mx="${mx%%+*}"; my="${geom##*+}"
  
  out="$(xdotool getwindowgeometry --shell "$wid" 2>/dev/null || true)"
  eval "$(printf '%s\n' "$out" | grep -E '^(WIDTH|HEIGHT)=')"
  [[ -z "${WIDTH:-}" || -z "${HEIGHT:-}" ]] && return 1
  
  x=$(( mx + (mw - WIDTH) / 2 ))
  y=$(( my + (mh - HEIGHT) / 2 ))
  xdotool windowmove --sync "$wid" "$x" "$y"
}

apply_rule() {
  local wid="$1" mon="$2" class="$3" name="$4"
  local rule r_class r_name r_w r_h r_state r_sticky r_delay r_action

  for rule in "${RULES[@]}"; do
    IFS='|' read -r r_class r_name r_w r_h r_state r_sticky r_delay r_action <<< "$rule"

    [[ "$class" != "$r_class" ]] && continue
    [[ "$r_name" != "*" && "$name" != "$r_name" ]] && continue
    [[ "$r_action" == "skip" ]] && return 0

    sleep "$r_delay"

    # SOLO aplica estado si se definió en la regla (no vacío)
    if [[ -n "$r_state" ]]; then
        bspc node "$wid" -t "$r_state"
    fi

    # Aplicar sticky
    [[ "$r_sticky" == "on" || "$r_sticky" == "off" ]] && bspc node "$wid" -g sticky="$r_sticky"

    case "$r_action" in
      "center")
        # Forzar tamaño r_w x r_h y centrar
        center_window_on_monitor "$wid" "$mon" "$r_w" "$r_h"
        ;;
      "float_center")
        # Centrar con tamaño actual
        for i in {1..5}; do center_current_size_on_monitor "$wid" "$mon" && break; sleep 0.05; done
        ;;
      "apply_props")
        ;;
    esac
    return 0
  done
}

watch_window() {
  local mon="$1" wid="$2"
  local i props class name
  for i in {1..15}; do
    props="$(get_props "$wid")"
    class="$(printf '%s\n' "$props" | extract_class)"
    name="$(printf '%s\n' "$props" | extract_name)"
    if [[ -n "$class" ]]; then
      apply_rule "$wid" "$mon" "$class" "$name" && return 0
    fi
    sleep 0.12
  done
}

# --- BUCLE PRINCIPAL ---

bspc subscribe node_add node_geometry | while read -r evt a b c d; do
  case "$evt" in
    node_add) mon_id="$a"; wid="$d" ;;
    node_geometry) mon_id="$a"; wid="$c" ;;
    *) continue ;;
  esac

  [[ -z "${wid:-}" || "$wid" == "0x00000000" ]] && continue

  (
    lockfile="$LOCK_DIR/${wid}.lock"
    exec 9>"$lockfile"
    flock -n 9 || exit 0

    mon="$(get_monitor_name_by_id "$mon_id" 2>/dev/null || true)"
    [[ -z "$mon" ]] && mon="$(xrandr --query | awk '/ connected primary/ {print $1; exit}')"
    [[ -z "$mon" ]] && mon="$(xrandr --query | awk '/ connected/ {print $1; exit}')"

    watch_window "$mon" "$wid"
    rm -f "$lockfile"
  ) &
done