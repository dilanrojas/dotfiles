#!/usr/bin/env bash
set -uo pipefail

WARN_LEVEL=20
CRIT_LEVEL=10
POLL_INTERVAL=120

SONG="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"

LOCKFILE="/tmp/battery-monitor.lock"
exec 200>"$LOCKFILE"
flock -n 200 || {
  echo "Already running."
  exit 1
}

BATTERY_PATH=$(find /sys/class/power_supply -maxdepth 1 -iname 'BAT*' | head -n1)
if [ -z "$BATTERY_PATH" ]; then
  echo "No battery found, exiting." >&2
  exit 1
fi

play_song() {
  if [ -f "$SONG" ]; then
    mpv --no-video --really-quiet "$SONG" &
  fi
}

NOTIFIED_20=false
NOTIFIED_10=false

while true; do
  CAPACITY=$(cat "$BATTERY_PATH/capacity" 2>/dev/null)
  STATUS=$(cat "$BATTERY_PATH/status" 2>/dev/null)

  if ! [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
    sleep "$POLL_INTERVAL"
    continue
  fi

  if [ "$STATUS" == "Discharging" ]; then
    if [ "$CAPACITY" -le "$CRIT_LEVEL" ] && [ "$NOTIFIED_10" = false ]; then
      notify-send -i /usr/share/icons/Papirus/48x48/status/battery-empty.svg -u critical "Battery Critical" "Battery is at ${CAPACITY}%."
      play_song
      NOTIFIED_10=true
      NOTIFIED_20=true
    elif [ "$CAPACITY" -le "$WARN_LEVEL" ] && [ "$CAPACITY" -gt "$CRIT_LEVEL" ] && [ "$NOTIFIED_20" = false ]; then
      notify-send -i /usr/share/icons/Papirus/48x48/status/battery-low.svg -u normal "Low Battery" "Battery is at ${CAPACITY}%."
      play_song
      NOTIFIED_20=true
    fi
  else
    NOTIFIED_20=false
    NOTIFIED_10=false
  fi

  sleep "$POLL_INTERVAL"
done
