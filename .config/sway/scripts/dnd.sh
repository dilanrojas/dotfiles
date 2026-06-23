#!/usr/bin/env bash

if dunstctl is-paused | grep -q "true"; then
  dunstctl set-paused false
  notify-send -i /usr/share/icons/Papirus/48x48/apps/preferences-desktop-notification-bell.svg "Dunst" "Notifications Enabled"
  sleep 1
  dunstctl close-all
else
  notify-send -i /usr/share/icons/Papirus/48x48/status/notification-disabled.svg "Dunst" "Notifications Disabled"
  sleep 1
  dunstctl close-all
  dunstctl set-paused true
fi
