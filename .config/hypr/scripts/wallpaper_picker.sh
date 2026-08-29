#!/usr/bin/env bash
# wallpaper_picker.sh — pick a wallpaper for the CURRENT theme and persist it.
set -uo pipefail

source "$HOME/.config/hypr/themes/lib.sh"

load_current
THEME="$CUR_THEME"
[ -n "$THEME" ] || {
  notify-send "Wallpaper" "Could not determine current theme"
  exit 1
}

CFG_FILE="$THEMES_DIR/$THEME/config.json"
[ -f "$CFG_FILE" ] || {
  notify-send "Wallpaper" "Theme '$THEME' not found"
  exit 1
}

WALLPAPER_DIR="$THEMES_DIR/$THEME/wallpapers"
[ -d "$WALLPAPER_DIR" ] || {
  notify-send "Wallpaper" "Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
}

MENU_ITEMS=""
while IFS= read -r file; do
  filename=$(basename "$file")
  MENU_ITEMS+="${filename}\x00icon\x1f${file}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort -f)
MENU_ITEMS="${MENU_ITEMS%\\n}"

CHOICE=$(
  echo -e "$MENU_ITEMS" | rofi -dmenu -i -p "Wallpaper" -theme-str '
    window { width: 1280px; }
    listview { columns: 4; lines: 1; }
    element { orientation: vertical; padding: 0px; spacing: 0px; }
    element-icon { size: 28ch; }
    element-text { enabled: true; horizontal-align: 0.5; padding: 0px 0px 15px 0px; }
  '
)
[ -z "$CHOICE" ] && exit 0

FULL_PATH="$WALLPAPER_DIR/$CHOICE"
[ -f "$FULL_PATH" ] || {
  notify-send "Wallpaper" "Wallpaper not found: $CHOICE"
  exit 1
}

# Apply immediately
hyprctl hyprpaper preload "$FULL_PATH" 2>/dev/null
hyprctl hyprpaper wallpaper ",$FULL_PATH" 2>/dev/null
CONFIG_PATH="${FULL_PATH/#$HOME/\~}"
sed -i "s|^[[:space:]]*path = .*|    path = $CONFIG_PATH|" "$HYPRPAPER_CONF"

# Persist into the theme's config.json
TMP_FILE=$(mktemp)
if jq --arg wp "$CHOICE" '.wallpaper = $wp' "$CFG_FILE" >"$TMP_FILE"; then
  mv "$TMP_FILE" "$CFG_FILE"
else
  rm -f "$TMP_FILE"
  notify-send "Wallpaper" "Failed to update theme configuration"
  exit 1
fi
