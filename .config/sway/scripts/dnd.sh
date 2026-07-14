#!/usr/bin/env bash
ACTION=$(echo "$1" | tr '[:upper:]' '[:lower:]')

WAYBAR_SIGNAL=8

enable_dunst() {
  dunstctl set-paused false
  pkill -RTMIN+8 waybar
  (
    # notify-send -i /usr/share/icons/Papirus/48x48/apps/preferences-desktop-notification-bell.svg "Dunst" "Notifications Enabled"
    sleep 1
    dunstctl close-all
  ) &
}

disable_dunst() {
  dunstctl set-paused true
  pkill -RTMIN+8 waybar
  # notify-send -i /usr/share/icons/Papirus/48x48/status/notification-disabled.svg "Dunst" "Notifications Disabled"
  (
    sleep 1
    dunstctl close-all
  ) &
}

if [ "$ACTION" = "off" ]; then
  enable_dunst
elif [ "$ACTION" = "on" ]; then
  disable_dunst
else
  if dunstctl is-paused | grep -q "true"; then
    enable_dunst
  else
    disable_dunst
  fi
fi

pkill -RTMIN+"$WAYBAR_SIGNAL" waybar
