#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWAY_CONFIG="$HOME/.config/sway/config.d/06-looks"

MENU_ITEMS=""

while IFS= read -r file; do
  basename=$(basename "$file")
  MENU_ITEMS+="${basename}\x00icon\x1f${file}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort -f)

CHOICE=$(echo -e "$MENU_ITEMS" | rofi -theme-str 'window { width: 800px; }' -dmenu -i -p "Wallpaper" \
  -theme-str 'element { orientation: vertical; } element-icon { size: 13ch; } listview { columns: 4; lines: 3; }')

if [ -n "$CHOICE" ]; then
  FULL_PATH="$WALLPAPER_DIR/$CHOICE"

  swaymsg "output * bg \"$FULL_PATH\" fill"

  sed -i "s|output \* bg .* fill|output * bg $FULL_PATH fill|" "$SWAY_CONFIG"
fi
