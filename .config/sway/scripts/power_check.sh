#!/bin/bash

if [ -n "$POWER_SUPPLY_ONLINE" ]; then
  AC_STATE="$POWER_SUPPLY_ONLINE"
else
  sleep 0.2
  AC_STATE=$(cat /sys/class/power_supply/AC/online 2>/dev/null)
fi

if [ "$AC_STATE" = "1" ]; then
  # === PLUGGED IN ===
  powerprofilesctl set balanced

  "$HOME"/.config/sway/scripts/toggle_effects.sh on

else
  # === ON BATTERY ===
  powerprofilesctl set power-saver

  "$HOME"/.config/sway/scripts/toggle_effects.sh off
fi

exit 0
