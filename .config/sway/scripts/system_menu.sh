#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/sway
SCRIPTS="$CFG/scripts"

ITEMS=(
  "󰤨  WiFi::$TERMINAL wlctl"
  "  Bluetooth::$TERMINAL bluetui"
  "  Update System::sh $SCRIPTS/update_system.sh"
  "󱥚  Sway Theme::sh $SCRIPTS/sway_theme.sh"
  "  Wallpaper Picker::sh $SCRIPTS/wallpaper_picker.sh"
  "󰍹  Monitors Config::$TERMINAL nvim $CFG/config.d/01-monitors"
  "󱞟  Mirror Monitor::$SCRIPTS/mirroring.sh"
  "󰌌  Keybindings Config::$TERMINAL nvim $CFG/config.d/04-keybindings"
  "󰍽  Input Config::$TERMINAL nvim $CFG/config.d/05-input"
  "  Autostart Config::$TERMINAL nvim $CFG/config.d/03-autostart"
  "  Looks Config::$TERMINAL nvim $CFG/config.d/06-looks"
  "󰫧  Variables Config::$TERMINAL nvim $CFG/config.d/02-variables"
  "  Window Rules Config::$TERMINAL nvim $CFG/config.d/07-rules"
  "  Scripts Folder::$TERMINAL nvim $CFG/scripts"
  "󰂚  Notification History::$SCRIPTS/notification_history.sh"
  "󰌁  Toggle Effects::$SCRIPTS/toggle_effects.sh"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "System Utilities" \
      -theme-str 'window {width: 300px; }'
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
