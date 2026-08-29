#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/waybar
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ITEMS=(
  "  Config::$TERMINAL nvim $CFG/config.jsonc"
  "  Style::$TERMINAL nvim $CFG/style.css"
  "  Theme::$TERMINAL nvim $CFG/theme.css"
)

CHOICE=$(printf "%s\n" "${ITEMS[@]}" | "$SCRIPT_DIR/rofi.sh" -L -p "Waybar Config" -w 280px)

if [[ -n "$CHOICE" ]]; then
  for item in "${ITEMS[@]}"; do
    label="${item%%::*}"
    cmd="${item#*::}"
    if [[ "$label" == "$CHOICE" ]]; then
      eval "$cmd"
      break
    fi
  done
fi
