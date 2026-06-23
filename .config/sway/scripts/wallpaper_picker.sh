#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWAY_CONFIG="$HOME/.config/sway/config"

# 1. Gather images and format them with Rofi icons for visual previews
MENU_ITEMS=""
while IFS= read -r file; do
  basename=$(basename "$file")
  # Format passes the filename as the text and the full path as the icon
  MENU_ITEMS+="${basename}\x00icon\x1f${file}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

# 2. Run Rofi in a grid layout to act as a gallery
CHOICE=$(echo -e "$MENU_ITEMS" | rofi -theme-str 'window { width: 800px; height: 650px; }' -dmenu -i -p "Wallpaper" \
  -theme-str 'element { orientation: vertical; } element-icon { size: 13ch; } listview { columns: 4; lines: 4; }')

# 3. Apply changes if a selection was made
if [ -n "$CHOICE" ]; then
  FULL_PATH="$WALLPAPER_DIR/$CHOICE"

  # Live update the current workspace wallpaper immediately via swaymsg
  swaymsg "output * bg \"$FULL_PATH\" fill"

  # Persist the change by replacing the line inside your sway/config
  # We escape the asterisk (\*) so sed treats it as a literal character
  sed -i "s|output \* bg .* fill|output * bg $FULL_PATH fill|" "$SWAY_CONFIG"
fi
