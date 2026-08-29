#!/usr/bin/env bash
# Event-driven: AC profile switching + low-battery alerts via UPower D-Bus.
# Reacts instantly to plug/unplug and battery level changes. No polling, no udev.
#
# Uses `gdbus monitor` (a normal, user-permitted D-Bus signal subscription).
# Falls back to a light sysfs poll if gdbus is unavailable.
set -uo pipefail

SERVICE=org.freedesktop.UPower
AC_PATH=/org/freedesktop/UPower/devices/line_power_ADP0
BAT_PATH=/org/freedesktop/UPower/devices/battery_BAT0

WARN_LEVEL=20
CRIT_LEVEL=10

LOCKFILE=/tmp/power-monitor.lock
exec 200>"$LOCKFILE"; flock -n 200 || { echo "Already running." >&2; exit 1; }

command -v powerprofilesctl >/dev/null 2>&1 || exit 1
have(){ command -v "$1" >/dev/null 2>&1; }

last_ac=""
apply_ac(){
  local online
  online=$(busctl --system get-property "$SERVICE" "$AC_PATH" \
            org.freedesktop.UPower.Device Online 2>/dev/null)
  [ "$online" = "$last_ac" ] && return
  last_ac="$online"
  if [ "$online" = "b true" ]; then
    powerprofilesctl set balanced
  else
    powerprofilesctl set power-saver
  fi
}

NOTIFIED_20=false; NOTIFIED_10=false
apply_bat(){
  local pct state
  pct=$(busctl --system get-property "$SERVICE" "$BAT_PATH" \
         org.freedesktop.UPower.Device Percentage 2>/dev/null | grep -oE '[0-9.]+')
  state=$(busctl --system get-property "$SERVICE" "$BAT_PATH" \
           org.freedesktop.UPower.Device State 2>/dev/null)
  if [ "$state" = "u 2" ]; then
    if [ "${pct:-100}" -le "$CRIT_LEVEL" ] && [ "$NOTIFIED_10" = false ]; then
      have notify-send && notify-send -i /usr/share/icons/Papirus/48x48/status/battery-empty.svg -u critical "Battery Critical" "Battery is at ${pct}%."
      NOTIFIED_10=true; NOTIFIED_20=true
    elif [ "${pct:-100}" -le "$WARN_LEVEL" ] && [ "$NOTIFIED_20" = false ]; then
      have notify-send && notify-send -i /usr/share/icons/Papirus/48x48/status/battery-low.svg -u normal "Low Battery" "Battery is at ${pct}%."
      NOTIFIED_20=true
    fi
  else
    NOTIFIED_20=false; NOTIFIED_10=false
  fi
}

# Initial: set the correct profile and prime the guard.
last_ac=$(busctl --system get-property "$SERVICE" "$AC_PATH" \
           org.freedesktop.UPower.Device Online 2>/dev/null)
if [ "$last_ac" = "b true" ]; then
  powerprofilesctl set balanced
else
  powerprofilesctl set power-saver
fi
apply_bat   # initial battery eval (guarded, silent unless already critical)

# ---- main loop ----
if have gdbus && busctl --system list 2>/dev/null | grep -q "^org.freedesktop.UPower"; then
  # Event-driven: react to any UPower PropertiesChanged signal.
  while true; do
    while IFS= read -r line; do
      case "$line" in
        *line_power*PropertiesChanged*) apply_ac ;;
        *battery*PropertiesChanged*)    apply_bat ;;
      esac
    done < <(stdbuf -o0 gdbus monitor --system --dest "$SERVICE" 2>/dev/null)
    sleep 1   # restart monitor if it ever exits
  done
else
  # Fallback: light poll (only acts on actual state change, guarded above).
  while true; do
    apply_ac; apply_bat
    sleep 2
  done
fi
