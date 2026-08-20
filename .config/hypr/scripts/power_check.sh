#!/bin/bash

set -u

# Check if powerprofilesctl exists
if ! command -v powerprofilesctl >/dev/null 2>&1; then
  exit 0
fi

AC_ONLINE=""

# If called by udev, use the supplied value
if [ -n "${POWER_SUPPLY_ONLINE:-}" ]; then
  AC_ONLINE="$POWER_SUPPLY_ONLINE"
else
  # Allow sysfs to update after hotplug events
  sleep 0.2

  AC_ONLINE=0

  for ps in /sys/class/power_supply/*; do
    [ -r "$ps/type" ] || continue

    type=$(<"$ps/type")

    case "$type" in
    Mains | AC | USB)
      if [ -r "$ps/online" ] && [ "$(<"$ps/online")" = "1" ]; then
        AC_ONLINE=1
        break
      fi
      ;;
    esac
  done
fi

case "$AC_ONLINE" in
1)
  powerprofilesctl set balanced 2>/dev/null
  ;;
0)
  powerprofilesctl set power-saver 2>/dev/null
  ;;
*)
  exit 0
  ;;
esac

exit 0
