#!/usr/bin/env bash
# hypr_theme.sh — switch Hyprland theme. Source of truth: ~/.config/hypr/themes/<key>/
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$HOME/.config/hypr/themes/lib.sh"

# ------------------------------------------------------------------------------
# Theme menu (when no argument is given)
# ------------------------------------------------------------------------------
if [ -z "${1:-}" ]; then
  # Single jq pass over every theme config (cheap; avoids spawning jq per theme)
  MENU_ITEMS=$(jq -r --arg base "$THEMES_DIR" '
    (input_filename | capture(".*/(?<k>[^/]+)/config.json") | .k) as $key
    | "\($key)\t\(.label // $key)\\x00icon\\x1f\($base)/\($key)/preview.png"
  ' "$THEMES_DIR"/*/config.json)
  MENU_ITEMS="${MENU_ITEMS%\\n}"

  THEME=$(
    echo -e "$MENU_ITEMS" | rofi -dmenu -i -p "Select Theme" -display-columns 2 \
      -theme-str '
        window { width: 1280px; height: 403px; }
        listview { columns: 4; lines: 1; spacing: 5px; }
        element { orientation: vertical; padding: 0px; spacing: 0px; }
        element-icon { size: 28ch; }
        element-text { enabled: true; horizontal-align: 0.5; padding: 10px 00px; }
        element selected.normal { color: @bg-primary; background-color: @accent; }
      ' |
      cut -f1
  )
  [ -z "$THEME" ] && exit 0
else
  THEME="$1"
fi

# Verify theme exists
if [ ! -f "$THEMES_DIR/$THEME/config.json" ]; then
  echo "Error: Theme '$THEME' not found in $THEMES_DIR"
  exit 1
fi

load_current
apply_theme "$THEME"

# Restart OSD server so the new colors load
pkill swayosd-server 2>/dev/null
swayosd-server >/dev/null 2>&1 &

# Reload dunst so the new colors load
pkill dunst 2>/dev/null

echo "Theme set to $THEME"
