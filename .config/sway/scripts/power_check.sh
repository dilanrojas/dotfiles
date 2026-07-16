#!/bin/bash

# If provided by udev, use it.
if [ -n "$POWER_SUPPLY_ONLINE" ]; then
  AC_ONLINE="$POWER_SUPPLY_ONLINE"
else
  sleep 0.2

  AC_ONLINE=0

  for ps in /sys/class/power_supply/*; do
    [ -r "$ps/type" ] || continue

    if [ "$(cat "$ps/type")" = "Mains" ]; then
      AC_ONLINE=$(cat "$ps/online" 2>/dev/null)
      break
    fi
  done
fi

if [ "$AC_ONLINE" = "1" ]; then
  # === PLUGGED IN ===
  powerprofilesctl set balanced
  "$HOME/.config/sway/scripts/toggle_effects.sh" on
else
  # === ON BATTERY ===
  powerprofilesctl set power-saver
  "$HOME/.config/sway/scripts/toggle_effects.sh" off
fi

exit 0
