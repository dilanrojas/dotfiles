#!/usr/bin/env bash

# Nerd Font icons
PERF="󰓅  Performance"
BAL="󰾅  Balanced"
SAVE="󰾆  Power Saver"

choice=$(printf "%s\n%s\n%s\n" \
  "$PERF" \
  "$BAL" \
  "$SAVE" | rofi -no-show-icons -dmenu -i -p "Power Profile" -theme-str 'window {width: 230px; height: 243px; }')

case "$choice" in
"$PERF")
  powerprofilesctl set performance
  ;;
"$BAL")
  powerprofilesctl set balanced
  ;;
"$SAVE")
  powerprofilesctl set power-saver
  ;;
esac
