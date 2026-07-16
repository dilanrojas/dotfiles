#!/bin/bash

SESSION=$(loginctl show-seat seat0 -p ActiveSession --value)

if [ -z "$SESSION" ] || [ "$SESSION" = "no-session" ]; then
  exit 0
fi

USER_NAME=$(loginctl show-session "$SESSION" -p Name --value)
USER_ID=$(loginctl show-session "$SESSION" -p User --value)

export SWAYSOCK=$(ls /run/user/"$USER_ID"/sway-ipc."$USER_ID"*.sock 2>/dev/null | head -n 1)
if [ -z "$SWAYSOCK" ]; then
  exit 0
fi

if [ -n "$POWER_SUPPLY_ONLINE" ]; then
  AC_STATE="$POWER_SUPPLY_ONLINE"
else
  sleep 0.2
  AC_STATE=$(cat /sys/class/power_supply/AC/online 2>/dev/null)
fi

if [ "$AC_STATE" = "1" ]; then
  # === PLUGGED IN ===
  powerprofilesctl set balanced

  runuser -u "$USER_NAME" -- env \
    bash -c "/home/$USER_NAME/.config/sway/scripts/toggle_effects.sh on"

  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-plug.oga >/dev/null 2>&1 &
else
  # === ON BATTERY ===
  powerprofilesctl set power-saver

  runuser -u "$USER_NAME" -- env \
    bash -c "/home/$USER_NAME/.config/sway/scripts/toggle_effects.sh off"

  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-unplug.oga >/dev/null 2>&1 &
fi

exit 0
