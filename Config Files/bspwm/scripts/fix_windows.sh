#!/usr/bin/env bash
set -u

# FORMATO:
# 'CLASS|NAME|WIDTH|HEIGHT|STATE|STICKY|DELAY'
# NAME="*" aplica a cualquier ventana de esa clase
LOCK_DIR="/tmp/fix_windows_locks"
mkdir -p "$LOCK_DIR"
RULES=(
  'MEGAsync|Add sync|700|520|floating|off|0.35'
  'Nemo|File conflict|1000|500|floating|off|0.20'
)

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
  if [[ -z "$name" ]]; then
    name="$(sed -n 's/WM_NAME(STRING) = "\(.*\)"/\1/p' | head -n1)"
  fi
  printf '%s\n' "$name"
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

get_monitor_name_by_id() {
  local mid="$1"
  bspc query -M --names | while read -r mon; do
    local qid
    qid="$(bspc query -M -m "$mon" | head -n1 2>/dev/null || true)"
    if [[ "$qid" == "$mid" ]]; then
      printf '%s\n' "$mon"
      return 0
    fi
  done
}

center_window_on_monitor() {
  local wid="$1" mon="$2" w="$3" h="$4"
  local geom mw mh mx my x y

  geom="$(get_output_geometry "$mon")"
  [[ -n "$geom" ]] || return 1

  mw="${geom%%x*}"
  mh="${geom#*x}"
  mh="${mh%%+*}"

  mx="${geom#*+}"
  mx="${mx%%+*}"

  my="${geom##*+}"

  x=$(( mx + (mw - w) / 2 ))
  y=$(( my + (mh - h) / 2 ))

  xdotool windowsize --sync "$wid" "$w" "$h"
  xdotool windowmove --sync "$wid" "$x" "$y"
}

center_current_window_on_monitor() {
  local wid="$1" mon="$2"
  local geom mw mh mx my
  local WIDTH="" HEIGHT=""
  local x y out

  geom="$(get_output_geometry "$mon")"
  [[ -n "$geom" ]] || return 1

  mw="${geom%%x*}"
  mh="${geom#*x}"
  mh="${mh%%+*}"
  mx="${geom#*+}"
  mx="${mx%%+*}"
  my="${geom##*+}"

  out="$(xdotool getwindowgeometry --shell "$wid" 2>/dev/null || true)"
  eval "$(printf '%s\n' "$out" | grep -E '^(WIDTH|HEIGHT)=')"

  [[ -n "$WIDTH" && -n "$HEIGHT" ]] || return 1

  x=$(( mx + (mw - WIDTH) / 2 ))
  y=$(( my + (mh - HEIGHT) / 2 ))

  xdotool windowmove --sync "$wid" "$x" "$y" 2>/dev/null || return 1
}


enforce_center_on_monitor() {
  local wid="$1" mon="$2"
  local times="${3:-18}"
  local delay="${4:-0.15}"
  local i

  for ((i=1; i<=times; i++)); do
    center_current_window_on_monitor "$wid" "$mon"
    sleep "$delay"
  done
}

apply_rule() {
  local wid="$1" mon="$2" class="$3" name="$4"
  local rule r_class r_name r_w r_h r_state r_sticky r_delay

  for rule in "${RULES[@]}"; do
    IFS='|' read -r r_class r_name r_w r_h r_state r_sticky r_delay <<< "$rule"

    [[ "$class" != "$r_class" ]] && continue
    [[ "$r_name" != "*" && "$name" != "$r_name" ]] && continue

    sleep "$r_delay"

    [[ -n "$r_state" ]] && bspc node "$wid" -t "$r_state"
    [[ "$r_sticky" == "on" || "$r_sticky" == "off" ]] && bspc node "$wid" -g sticky="$r_sticky"

    if [[ "$class" == "Nemo" && "$name" == "File conflict" ]]; then
      bspc config -n "$wid" border_width 4
      enforce_center_on_monitor "$wid" "$mon" 18 0.15
      printf 'FIXED wid=%s mon=%s class=%s name=%s border=4 center=current\n' \
        "$wid" "$mon" "$class" "$name"
    else
      center_window_on_monitor "$wid" "$mon" "$r_w" "$r_h"
      printf 'FIXED wid=%s mon=%s class=%s name=%s size=%sx%s centered\n' \
        "$wid" "$mon" "$class" "$name" "$r_w" "$r_h"
    fi

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

bspc subscribe node_add node_geometry | while read -r evt a b c d; do
  case "$evt" in
    node_add)
      mon_id="$a"
      wid="$d"
      ;;
    node_geometry)
      mon_id="$a"
      wid="$c"
      ;;
    *)
      continue
      ;;
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
  ) &
done
