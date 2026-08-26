#!/usr/bin/env bash
SCRIPTS=~/.config/hypr/scripts

ITEMS=(
  "󱥚  Theme::sh $SCRIPTS/hypr_theme.sh"
  "  Wallpaper::sh $SCRIPTS/wallpaper_picker.sh"
  "󰌁  Toggle Effects::$SCRIPTS/toggle_effects.sh"
  "󰗘  Toggle Animations::$SCRIPTS/toggle_animations.sh"
  "  Toggle Gaps::$SCRIPTS/toggle_smart_gaps.sh"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "Looks" \
      -theme-str 'window { width: 280px; height: 358px; }'
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
