#!/usr/bin/env bash
set -euo pipefail

declare -A choice_map
lines=()

# Monitors
while IFS= read -r name; do
  label="󰹑  Monitor: $name"
  lines+=("$label")
  choice_map["$label"]="Monitor: $name"
done < <(swaymsg -t get_outputs | jq -r '.[].name')

# Windows (title, app-id, unique id)
while IFS=',' read -r id title appid; do
  [ -z "$id" ] && continue
  label="  ${appid} (${title}) #${id}"
  lines+=("$label")
  choice_map["$label"]="Window: $id"
done < <(lswt -c 'ita')

selection=$(printf '%s\n' "${lines[@]}" | rofi --theme-str 'window { width: 450px; }' -dmenu -no-show-icons -i -p "Share screen or window")

[ -n "$selection" ] && printf '%s' "${choice_map[$selection]}"
