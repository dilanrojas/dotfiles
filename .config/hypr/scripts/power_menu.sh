#!/usr/bin/env bash

# Define options using Nerd Font icons (optional, but looks great)
# If you don't use a Nerd Font, you can replace these with plain text.
shutdown="  Shutdown"
reboot="󰑙  Reboot"
lock="  Lock"
suspend="  Suspend"
logout="󰍂  Log Out"

# Ask rofi for a selection
chosen=$(echo -e "$shutdown\n$reboot\n$suspend\n$logout\n$lock" | rofi \
  -dmenu \
  -no-show-icons \
  -i \
  -p "Power Menu" \
  -theme-str 'window { width: 300px; height: 350px; }')

# Perform the action based on selection
case "$chosen" in
"$shutdown")
  systemctl poweroff
  ;;
"$reboot")
  systemctl reboot
  ;;
"$lock")
  hyprlock
  ;;
"$suspend")
  systemctl suspend
  ;;
"$logout")
  command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'
  ;;
esac
