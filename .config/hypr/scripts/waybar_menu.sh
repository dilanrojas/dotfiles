#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/waybar

ITEMS=(
  "  Config::$TERMINAL nvim $CFG/config.jsonc"
  "  Style::$TERMINAL nvim $CFG/style.css"
  "  Theme::$TERMINAL nvim $CFG/theme.css"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "Waybar Config" \
      -theme-str 'window { width: 280px; height: 245px; }'
)

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
