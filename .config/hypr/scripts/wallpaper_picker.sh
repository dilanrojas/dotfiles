#!/usr/bin/env bash

CURRENT_THEME="$HOME/.config/hypr/current_theme"
THEMES_JSON="$HOME/.config/hypr/themes.json"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Get the current theme key
THEME=$(sed -n 's/^THEME=//p' "$CURRENT_THEME")

if [ -z "$THEME" ]; then
  notify-send "Wallpaper" "Could not determine current theme"
  exit 1
fi

# Wallpaper directory for the current theme
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers/$THEME"

if [ ! -d "$WALLPAPER_DIR" ]; then
  notify-send "Wallpaper" "Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
fi

# Make sure the theme exists in the JSON
if ! jq -e --arg theme "$THEME" '.[$theme]' "$THEMES_JSON" >/dev/null; then
  notify-send "Wallpaper" "Theme '$THEME' not found in themes.json"
  exit 1
fi

# Build Rofi menu with image previews
MENU_ITEMS=""

while IFS= read -r file; do
  filename=$(basename "$file")
  MENU_ITEMS+="${filename}\x00icon\x1f${file}\n"
done < <(
  find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) |
    sort -f
)

# Remove trailing newline so rofi doesn't show an empty last entry
MENU_ITEMS="${MENU_ITEMS%\\n}"

CHOICE=$(
  echo -e "$MENU_ITEMS" |
    rofi \
      -dmenu \
      -i \
      -p "Wallpaper" \
      -theme-str '
        window {
          width: 1000px;
          height: 403px;
        }

        listview {
          columns: 3;
          lines: 1;
          spacing: 5px;
        }

        element {
          orientation: vertical;
          padding: 0px;
          spacing: 0px;
        }

        element selected.normal {
          background-color: @accent;
        }

        element-icon {
          size: 28ch;
        }

        element-text {
          enabled: true;
          horizontal-align: 0.5;
          padding: 10px 00px;
        }

        element selected.normal {
          color: @bg-primary;
          background-color: @accent;
        }
      '
)

# Nothing selected
if [ -z "$CHOICE" ]; then
  exit 0
fi

FULL_PATH="$WALLPAPER_DIR/$CHOICE"

# Make sure selected file exists
if [ ! -f "$FULL_PATH" ]; then
  notify-send "Wallpaper" "Wallpaper not found: $CHOICE"
  exit 1
fi

# Apply wallpaper immediately
hyprctl hyprpaper preload "$FULL_PATH"
hyprctl hyprpaper wallpaper ",$FULL_PATH"

# Convert /home/user/... -> ~/...
CONFIG_PATH="${FULL_PATH/#$HOME/\~}"

# Update hyprpaper.conf
sed -i "s|^[[:space:]]*path = .*|    path = $CONFIG_PATH|" "$HYPRPAPER_CONFIG"

# Update the wallpaper for ONLY the current theme in themes.json
TMP_FILE=$(mktemp)

if jq --arg theme "$THEME" \
  --arg wallpaper "$CHOICE" \
  '.[$theme].wallpaper = $wallpaper' \
  "$THEMES_JSON" >"$TMP_FILE"; then

  mv "$TMP_FILE" "$THEMES_JSON"

else
  rm -f "$TMP_FILE"
  notify-send "Wallpaper" "Failed to update theme configuration"
  exit 1
fi
