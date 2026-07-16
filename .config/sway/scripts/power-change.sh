#!/bin/bash

USER_ID=$(id -u)

export SWAYSOCK=$(ls /run/user/"$USER_ID"/sway-ipc."$USER_ID"*.sock 2>/dev/null | head -n 1)

AC_STATE=$(cat /sys/class/power_supply/AC/online)

if [ -z "$SWAYSOCK" ]; then
  echo "Sway is not running right now. Exiting."
  exit 0
fi

if [ "$AC_STATE" = "1" ]; then
  # === WHAT TO DO WHEN PLUGGED IN ===
  powerprofilesctl set balanced
  mpv --no-video /usr/share/sounds/freedesktop/stereo/power-plug.oga

else
  # === WHAT TO DO WHEN UNPLUGGED (ON BATTERY) ===
  powerprofilesctl set power-saver
  mpv --no-video /usr/share/sounds/freedesktop/stereo/power-unplug.oga

fi
