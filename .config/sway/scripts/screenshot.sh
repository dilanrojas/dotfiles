#!/usr/bin/env bash

# Ensure the screenshot save directory exists
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

# Main Rofi Menu options
OPTIONS="󰆞  Crop Selection\n󰹑  Fullscreen\n󱂵  Active Window"
CHOICE=$(echo -e "$OPTIONS" | rofi -no-show-icons -dmenu -i -p "Screenshot" -theme-str 'window {width: 230px; height: 250px; }')

# Helper to pipe into swappy with an explicit save directory and filename template
run_swappy() {
  swappy -f - -o "$SAVE_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
}

case "$CHOICE" in
*"Crop Selection"*)
  grimshot save area - | run_swappy
  ;;
*"Fullscreen"*)
  grimshot save screen - | run_swappy
  ;;
*"Active Window"*)
  grimshot save active - | run_swappy
  ;;
*)
  exit 0
  ;;
esac
