#!/usr/bin/env bash
set -euo pipefail

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

capture_screenshot() {
  local mode="$1"
  local filename
  filename="$(date +'%Y-%m-%d-%H%M%S')_grimblast.png"

  local target
  local flags=(--notify)

  case "$mode" in
  area)
    # Covers both "crop" (drag a region) and "window" (click a window) --
    # grimblast's slurp-based area selection handles both interactions.
    target="area"
    flags+=(--freeze)
    ;;
  active)
    target="active"
    ;;
  full)
    target="output"
    ;;
  *)
    exit 1
    ;;
  esac

  # grimblast handles saving + clipboard copy + notification itself.
  # A non-zero exit (e.g. selection cancelled) just means nothing to do.
  grimblast "${flags[@]}" copysave "$target" "$SAVE_DIR/$filename" || exit 0
}

if [[ $# -gt 0 ]]; then
  case "$1" in
  crop) capture_screenshot area ;;
  window) capture_screenshot area ;;
  active) capture_screenshot active ;;
  full) capture_screenshot full ;;
  *)
    echo "Usage: $0 [crop|window|active|full]"
    exit 1
    ;;
  esac
else
  OPTIONS="󰆞  Crop Selection\n󰖯  Window Selection\n󰹑  Fullscreen\n󱂵  Active Window"
  CHOICE=$(echo -e "$OPTIONS" | rofi \
    -dmenu \
    -i \
    -no-show-icons \
    -p "Screenshot" \
    -theme-str 'window {width: 230px; height: 290px;}')
  [[ -z "$CHOICE" ]] && exit 0
  sleep 0.4
  case "$CHOICE" in
  *"Crop Selection"*) capture_screenshot area ;;
  *"Window Selection"*) capture_screenshot area ;;
  *"Fullscreen"*) capture_screenshot full ;;
  *"Active Window"*) capture_screenshot active ;;
  *) exit 0 ;;
  esac
fi
