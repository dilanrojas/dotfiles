#!/usr/bin/env bash
set -euo pipefail

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
SCREENSHOT_FILE="$SAVE_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

capture_screenshot() {
  local mode="$1"
  grimshot save "$mode" "$SCREENSHOT_FILE"
  if [[ ! -f "$SCREENSHOT_FILE" ]]; then
    notify-send "Screenshot Failed"
    exit 1
  fi
  wl-copy <"$SCREENSHOT_FILE"
}

# If a flag is passed, skip rofi and capture directly
if [[ $# -gt 0 ]]; then
  case "$1" in
  crop) capture_screenshot area ;;
  active) capture_screenshot active ;;
  full) capture_screenshot screen ;;
  *)
    echo "Usage: $0 [crop|active|full]"
    exit 1
    ;;
  esac
else
  OPTIONS="󰆞  Crop Selection\n󰹑  Fullscreen\n󱂵  Active Window"
  CHOICE=$(echo -e "$OPTIONS" | rofi \
    -dmenu \
    -i \
    -no-show-icons \
    -p "Screenshot" \
    -theme-str 'window {width: 230px; height: 250px; }')

  [ -z "$CHOICE" ] && exit 0

  case "$CHOICE" in
  *"Crop Selection"*) capture_screenshot area ;;
  *"Fullscreen"*) capture_screenshot screen ;;
  *"Active Window"*) capture_screenshot active ;;
  *) exit 0 ;;
  esac
fi

ACTION=$(
  notify-send \
    "Screenshot Saved" \
    "Copied to clipboard" \
    --icon="$SCREENSHOT_FILE" \
    --action="edit,Edit in Swappy" \
    --wait \
    --expire-time=10000
)

if [[ "$ACTION" == "0" ]]; then
  swappy -f "$SCREENSHOT_FILE" -o "$SCREENSHOT_FILE"
fi
