#!/usr/bin/env bash

# Nerd Font icons
PERF="󰓅  Performance"
BAL="󰾅  Balanced"
SAVE="󰾆  Power Saver"

choice=$(printf "%s\n%s\n%s\n" \
  "$PERF" \
  "$BAL" \
  "$SAVE" | "$(dirname "${BASH_SOURCE[0]}")/rofi.sh" -p "Power Profile" -w 230px)

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
