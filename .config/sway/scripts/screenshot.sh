#!/bin/bash

mkdir -p ~/Pictures/Screenshots

FILENAME="screenshot-$(date +%F-%T).png"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"

if grim "$FILEPATH"; then
  wl-copy <"$FILEPATH"

  ACTION=$(notify-send 'Screenshot' 'Copied to clipboard and saved to Pictures' \
    -a GRIM \
    -i "$FILEPATH" \
    --action "default=Open Image")

  case "$ACTION" in
  "default")
    xdg-open "$FILEPATH" &
    ;;
  esac
fi
