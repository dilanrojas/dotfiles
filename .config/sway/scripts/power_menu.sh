#!/usr/bin/env bash

# Define options using Nerd Font icons (optional, but looks great)
# If you don't use a Nerd Font, you can replace these with plain text.
shutdown="  Power Off"
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
  -theme-str 'window { width: 300px; }')

# Perform the action based on selection
case "$chosen" in
"$shutdown")
  systemctl poweroff
  ;;
"$reboot")
  systemctl reboot
  ;;
"$lock")
  swaylock -f
  ;;
"$suspend")
  systemctl suspend
  ;;
"$logout")
  swaymsg exit
  ;;
esac
