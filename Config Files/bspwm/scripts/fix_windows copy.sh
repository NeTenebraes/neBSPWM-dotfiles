#!/usr/bin/env bash
set -u

# ==============================================================================
# FIX WINDOWS - BSPWM HELPER SCRIPT
# ==============================================================================
# Formato de las reglas: 'CLASS|NAME|WIDTH|HEIGHT|STATE|STICKY|DELAY|ACTION'
# 
# NOTA SOBRE NAME: Ahora soporta coincidencia parcial. Si pones "RuneLite", 
# coincidirá con "RuneLite", "RuneLite - Personaje", etc.
# ==============================================================================

RULES=(
  'MEGAsync|Add sync|700|520|floating|off|0.35|center'
  'Nemo|File conflict|0|0|floating|off|0.01|float_center'
  
  # --- ESTRATEGIA PARA RUNELITE ---

  # 1. ESPECÍFICA: El PiP (siempre primero)
  'net-runelite-client-RuneLite|Picture in Picture|0|0|floating|on|0.001|bottom_right'
  
  # 2. EXCEPCIÓN: Si el nombre es EXACTAMENTE "RuneLite", es el lanzador o el cliente sin loguear.
  'net-runelite-client-RuneLite|^RuneLite$|0|0||off|0.1|skip'
  
  # 3. CLIENTE LOGUEADO: Si el nombre empieza con "RuneLite -", es el juego principal.
  # Usamos el prefijo "RuneLite -" para diferenciarlo de otros popups.
  'net-runelite-client-RuneLite|RuneLite -|0|0||off|0.1|skip'
  
  # 4. COMODÍN: Cualquier otra cosa que no sea lo anterior (popups, menús) se centra.
  'net-runelite-client-RuneLite|*|0|0|floating|off|0.01|float_center'
)

PADDING=5
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

move_to_corner() {
  local wid="$1" mon="$2" corner="$3"
  local geom mw mh mx my WIDTH HEIGHT x y out
  
  geom="$(get_output_geometry "$mon")"
  [[ -z "$geom" ]] && return 1
  mw="${geom%%x*}"; mh="${geom#*x}"; mh="${mh%%+*}"
  mx="${geom#*+}"; mx="${mx%%+*}"; my="${geom##*+}"
  
  out="$(xdotool getwindowgeometry --shell "$wid" 2>/dev/null || true)"
  eval "$(printf '%s\n' "$out" | grep -E '^(WIDTH|HEIGHT)=')"
  [[ -z "${WIDTH:-}" || -z "${HEIGHT:-}" ]] && return 1

  case "$corner" in
    "top_left")     x=$(( mx + PADDING )); y=$(( my + PADDING )) ;;
    "top_right")    x=$(( mx + mw - WIDTH - PADDING )); y=$(( my + PADDING )) ;;
    "bottom_left")  x=$(( mx + PADDING )); y=$(( my + mh - HEIGHT - PADDING )) ;;
    "bottom_right") x=$(( mx + mw - WIDTH - PADDING )); y=$(( my + mh - HEIGHT - PADDING )) ;;
  esac

  xdotool windowmove --sync "$wid" "$x" "$y"
}

center_window_on_monitor() {
  local wid="$1" mon="$2" w="$3" h="$4"
  local geom mw mh mx my x y
  geom="$(get_output_geometry "$mon")"
  [[ -z "$geom" ]] && return 1
  mw="${geom%%x*}"; mh="${geom#*x}"; mh="${mh%%+*}"
  mx="${geom#*+}"; mx="${mx%%+*}"; my="${geom##*+}"
  
  x=$(( mx + (mw - w) / 2 ))
  y=$(( my + (mh - h) / 2 ))

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
    
    # Lógica de coincidencia:
    if [[ "$r_name" == "*" ]]; then
        : # El asterisco coincide siempre, continuamos
    elif [[ "$r_name" == ^* ]]; then
        # Soporte opcional para Regex si empieza por ^
        [[ ! "$name" =~ ${r_name} ]] && continue
    else
        # Coincidencia por prefijo (esto arregla lo de RuneLite - Personaje)
        [[ "$name" != "$r_name"* ]] && continue
    fi

    [[ "$r_action" == "skip" ]] && return 0

    sleep "$r_delay"
    if [[ -n "$r_state" ]]; then bspc node "$wid" -t "$r_state"; fi
    [[ "$r_sticky" == "on" || "$r_sticky" == "off" ]] && bspc node "$wid" -g sticky="$r_sticky"

    case "$r_action" in
      "center") center_window_on_monitor "$wid" "$mon" "$r_w" "$r_h" ;;
      "float_center") for i in {1..5}; do center_current_size_on_monitor "$wid" "$mon" && break; sleep 0.05; done ;;
      "top_left"|"top_right"|"bottom_left"|"bottom_right") for i in {1..5}; do move_to_corner "$wid" "$mon" "$r_action" && break; sleep 0.05; done ;;
    esac
    return 0
  done
  return 1
}

watch_window() {
  local mon="$1" wid="$2"
  local i props class name
  for i in {1..20}; do
    props="$(get_props "$wid")"
    class="$(printf '%s\n' "$props" | extract_class)"
    name="$(printf '%s\n' "$props" | extract_name)"
    
    if [[ -n "$class" && ( -z "$name" || "$name" == "sun-awt-X11-XFramePeer" ) ]]; then
        name=$(xprop -id "$wid" _NET_WM_NAME 2>/dev/null | cut -d'"' -f2)
    fi

    if [[ -n "$class" ]]; then
      if apply_rule "$wid" "$mon" "$class" "$name"; then return 0; fi
    fi
    sleep 0.1
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