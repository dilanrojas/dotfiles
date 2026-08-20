#!/bin/bash

# ------------------------------------------------------------
# Detect AC power state
# ------------------------------------------------------------

AC_STATE=""

for ps in /sys/class/power_supply/*; do
  [ -r "$ps/type" ] || continue
  [ -r "$ps/online" ] || continue

  case "$(<"$ps/type")" in
  Mains | AC | USB)
    if [ "$(<"$ps/online")" = "1" ]; then
      AC_STATE="1"
      break
    fi

    # We found a valid mains-type supply, but it is offline.
    AC_STATE="0"
    ;;
  esac
done

# Couldn't determine power state
if [ -z "$AC_STATE" ]; then
  echo "Could not determine AC power state."
  exit 1
fi

# ------------------------------------------------------------
# Make sure powerprofilesctl exists
# ------------------------------------------------------------

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  echo "powerprofilesctl not found."
  exit 1
fi

# ------------------------------------------------------------
# AC connected
# ------------------------------------------------------------

if [ "$AC_STATE" = "1" ]; then

  powerprofilesctl set balanced

  mpv --no-video \
    /usr/share/sounds/freedesktop/stereo/power-plug.oga

# ------------------------------------------------------------
# On battery
# ------------------------------------------------------------

else

  powerprofilesctl set power-saver

  mpv --no-video \
    /usr/share/sounds/freedesktop/stereo/power-unplug.oga

fi
