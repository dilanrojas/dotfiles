#!/bin/bash

mkdir -p "$HOME/Pictures/Screenshots"

REGION=$(slurp) || exit 1
[ -z "$REGION" ] && exit 0

FILENAME="screenshot-$(date +%F-%H-%M-%S).png"
FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"

if grim -g "$REGION" "$FILEPATH"; then
  wl-copy --type image/png <"$FILEPATH"

  ACTION=$(notify-send \
    "Screenshot" \
    "Copied to clipboard and saved to Pictures" \
    -a GRIM \
    -i "$FILEPATH" \
    --action="default=Open Image")

  [ "$ACTION" = "default" ] && xdg-open "$FILEPATH" &
fi
