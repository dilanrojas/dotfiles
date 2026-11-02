#!/usr/bin/env bash
# Usage: spotify-controls prev|toggle|next
PLAYER="spotify"
BUTTON="$1"

trap 'pkill -P $$' EXIT
trap 'exit' TERM INT HUP

emit() {
  local status="$1" icon=""
  case "$status/$BUTTON" in
  Playing/prev | Paused/prev) icon="󰒮" ;;
  Playing/toggle) icon="󰐊" ;;
  Paused/toggle) icon="󰏤" ;;
  Playing/next | Paused/next) icon="󰒭" ;;
  esac

  if [ -z "$icon" ]; then
    echo '{"text":"","alt":"idle"}'
  else
    echo "{\"text\":\"$icon\",\"alt\":\"${status,,}\"}"
  fi
}

emit ""

while true; do
  last="__none__"
  # Process substitution keeps the loop in the main shell; no extra pipeline subshell
  while read -r status; do
    [ "$status" = "$last" ] && continue # skip repeats from track-change signals
    last="$status"
    emit "$status"
  done < <(playerctl --player "$PLAYER" metadata --follow --format '{{status}}' 2>/dev/null)
  emit ""
  sleep 2
done
