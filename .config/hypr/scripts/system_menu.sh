#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/hypr
SCRIPTS="$CFG/scripts"

ITEMS=(
  "  Power::$SCRIPTS/power_menu.sh"
  "  Apps::rofi -show drun"
  "󰤨  WiFi::$TERMINAL wlctl"
  "  Bluetooth::$TERMINAL bluetui"
  "󰆞  Screenshot::$SCRIPTS/screenshot.sh"
  "  Screen Recorder::sh $SCRIPTS/screenrecord.sh"
  "  Update System::sh $SCRIPTS/update_system.sh"
  "󱩌  Night Light::sh $SCRIPTS/night_light.sh"
  "  Hyprland::$SCRIPTS/hypr_menu.sh"
  "  Waybar::$SCRIPTS/waybar_menu.sh"
  "  Looks::$SCRIPTS/looks_menu.sh"
  "󰂚  Notification History::$SCRIPTS/notification_history.sh"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "System Utilities" \
      -theme-str 'window { width: 280px; height: 353px; }'
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
