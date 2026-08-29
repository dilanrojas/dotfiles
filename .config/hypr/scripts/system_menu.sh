#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/hypr
SCRIPTS="$CFG/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

CHOICE=$(printf "%s\n" "${ITEMS[@]}" | "$SCRIPT_DIR/rofi.sh" -L -p "System Utilities")

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
