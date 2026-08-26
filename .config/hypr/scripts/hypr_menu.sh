#!/usr/bin/env bash
TERMINAL="alacritty --class float -e"
CFG=~/.config/hypr
SCRIPTS="$CFG/scripts"

ITEMS=(
  "󰍹  Monitors::$TERMINAL nvim $CFG/config/monitors.lua"
  "󰌌  Keybindings::$TERMINAL nvim $CFG/config/keybindings.lua"
  "󰍽  Input::$TERMINAL nvim $CFG/config/input.lua"
  "  Autostart::$TERMINAL nvim $CFG/config/autostart.lua"
  "󰗀  Env::$TERMINAL nvim $CFG/config/env.lua"
  "󰎟  Misc::$TERMINAL nvim $CFG/config/misc.lua"
  "  Permissions::$TERMINAL nvim $CFG/config/permissions.lua"
  "  Looks::$TERMINAL nvim $CFG/config/looks.lua"
  "  Window Rules::$TERMINAL nvim $CFG/config/rules.lua"
  "  Scripts Folder::$TERMINAL nvim $CFG/scripts"
)

MENU=()
for item in "${ITEMS[@]}"; do
  MENU+=("${item%%::*}")
done

CHOICE=$(
  printf "%s\n" "${MENU[@]}" |
    rofi -no-show-icons -dmenu -i -p "Hyprland Config" \
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
