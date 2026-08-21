#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/hypr
SCRIPTS="$CFG/scripts"

ITEMS=(
  "  Power::$SCRIPTS/power_menu.sh"
  "󰤨  WiFi::$TERMINAL wlctl"
  "  Bluetooth::$TERMINAL bluetui"
  "󰆞  Screenshot::$SCRIPTS/screenshot.sh"
  "  Update System::sh $SCRIPTS/update_system.sh"
  "󱩌  Night Light::sh $SCRIPTS/night_light.sh"
  "  Wallpaper Picker::sh $SCRIPTS/wallpaper_picker.sh"
  "󰍹  Monitors Config::$TERMINAL nvim $CFG/config/monitors.lua"
  "󰌌  Keybindings Config::$TERMINAL nvim $CFG/config/keybindings.lua"
  "󰍽  Input Config::$TERMINAL nvim $CFG/config/input.lua"
  "  Autostart Config::$TERMINAL nvim $CFG/config/autostart.lua"
  "  Looks Config::$TERMINAL nvim $CFG/config/looks.lua"
  "󰫧  Variables Config::$TERMINAL nvim $CFG/config/variables.lua"
  "  Waybar Config::$TERMINAL nvim ~/.config/waybar/"
  "  Window Rules Config::$TERMINAL nvim $CFG/config/rules.lua"
  "  Scripts Folder::$TERMINAL nvim $CFG/scripts"
  "󰂚  Notification History::$SCRIPTS/notification_history.sh"
  "󰌁  Toggle Effects::$SCRIPTS/toggle_effects.sh"
  "  Smart Gaps::$SCRIPTS/toggle_smart_gaps.sh"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "System Utilities" \
      -theme-str 'window { width: 300px; height: 353px; }'
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
