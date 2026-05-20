#!/bin/bash

mkdir -p ~/Pictures/Screenshots

FILENAME="screenshot-$(date +%F-%T).png"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"

hyprpicker -q -z -r -b &

sleep 0.2

if grim "$FILEPATH"; then
  wl-copy <"$FILEPATH"
  notify-send 'Screenshot' 'Copied to clipboard and saved to Pictures' -a GRIM -i "$FILEPATH"
fi

pkill hyprpicker
