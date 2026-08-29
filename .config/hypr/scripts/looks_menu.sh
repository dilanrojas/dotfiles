#!/usr/bin/env bash
SCRIPTS=~/.config/hypr/scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ITEMS=(
  "󱥚  Theme::sh $SCRIPTS/hypr_theme.sh"
  "  Wallpaper::sh $SCRIPTS/wallpaper_picker.sh"
  "󰌁  Toggle Effects::$SCRIPTS/toggle_effects.sh"
  "󰗘  Toggle Animations::$SCRIPTS/toggle_animations.sh"
  "  Toggle Gaps::$SCRIPTS/toggle_smart_gaps.sh"
)

CHOICE=$(printf "%s\n" "${ITEMS[@]}" | "$SCRIPT_DIR/rofi.sh" -L -p "Looks")

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
