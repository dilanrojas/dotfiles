#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/hypr
SCRIPTS="$CFG/scripts"

ITEMS=(
  "󰍹  Monitors Config::$TERMINAL nvim $CFG/config/monitors.lua"
  "󰌌  Keybindings Config::$TERMINAL nvim $CFG/config/keybindings.lua"
  "󰍽  Input Config::$TERMINAL nvim $CFG/config/input.lua"
  "  Autostart Config::$TERMINAL nvim $CFG/config/autostart.lua"
  "󰗀  Env Config::$TERMINAL nvim $CFG/config/env.lua"
  "󰎟  Misc Config::$TERMINAL nvim $CFG/config/misc.lua"
  "  Permissions Config::$TERMINAL nvim $CFG/config/permissions.lua"
  "  Looks Config::$TERMINAL nvim $CFG/config/looks.lua"
  "  Window Rules Config::$TERMINAL nvim $CFG/config/rules.lua"
  "  Smart Gaps::$SCRIPTS/toggle_smart_gaps.sh"
  "  Scripts Folder::$TERMINAL nvim $CFG/scripts"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "Hyprland Config" \
      -theme-str 'window { width: 300px; height: 358px; }'
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
