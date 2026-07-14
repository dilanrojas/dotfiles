#!/bin/bash

mkdir -p ~/Pictures/Screenshots

FILENAME="screenshot-$(date +%F-%T).png"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"

hyprpicker -q -z -r -b &
HYPR_PID=$!

sleep 0.15

REGION=$(slurp)

if [ -z "$REGION" ]; then
  kill "$HYPR_PID" 2>/dev/null
  exit 0
fi

if grim -g "$REGION" "$FILEPATH"; then
  wl-copy <"$FILEPATH"
  notify-send 'Screenshot' 'Region copied to clipboard' -a GRIM -i "$FILEPATH"
fi

kill "$HYPR_PID" 2>/dev/null
