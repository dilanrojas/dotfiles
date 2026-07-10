#!/usr/bin/env bash

JSON_FILE="$HOME/.config/sway/themes.json"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
  echo "Error: $JSON_FILE not found."
  exit 1
fi

# If no theme argument is provided, prompt with Rofi
if [ -z "$1" ]; then
  THEME_LIST=$(jq -r 'keys[]' "$JSON_FILE")
  THEME=$(echo "$THEME_LIST" | rofi -no-show-icons -dmenu -p "Select Theme" -i)

  if [ -z "$THEME" ]; then
    exit 0
  fi
else
  THEME="$1"
fi

# Verify theme exists
if ! jq -e --arg theme "$THEME" '.[$theme]' "$JSON_FILE" >/dev/null; then
  echo "Error: Theme '$THEME' not found in $JSON_FILE"
  exit 1
fi

# Extract Theme-specific values safely
WALLPAPER=$(jq -r --arg theme "$THEME" '.[$theme].wallpaper' "$JSON_FILE")
NVIM_SCHEME=$(jq -r --arg theme "$THEME" '.[$theme].neovim_scheme' "$JSON_FILE")
ALACRITTY_THEME=$(jq -r --arg theme "$THEME" '.[$theme].alacritty_theme' "$JSON_FILE")
SYSTEM_THEME=$(jq -r --arg theme "$THEME" '.[$theme].system_theme // "dark"' "$JSON_FILE")

# Extract Shared palette
BG=$(jq -r --arg theme "$THEME" '.[$theme].palette.bg' "$JSON_FILE")
FG=$(jq -r --arg theme "$THEME" '.[$theme].palette.fg' "$JSON_FILE")
FG_SECONDARY=$(jq -r --arg theme "$THEME" '.[$theme].palette.fg_secondary' "$JSON_FILE")
ACCENT=$(jq -r --arg theme "$THEME" '.[$theme].palette.accent' "$JSON_FILE")
ACCENT_ACTIVE="$ACCENT"

eval "$(
  awk '
    /^\[colors\.normal\]/ { in_normal=1; next }
    /^\[/ { in_normal=0 }
    in_normal && /^[a-z]+[[:space:]]*=/ {
      split($0, a, "=")
      gsub(/[[:space:]\047]/, "", a[1])
      gsub(/[[:space:]\047]/, "", a[2])
      print toupper(a[1]) "=" a[2]
    }
  ' "$HOME/.config/alacritty/themes/${ALACRITTY_THEME}"
)"

# ------------------------------------------------------------------------------
# Waybar
# ------------------------------------------------------------------------------
# sed -i "s/\(@define-color bg \).*/\1$BG;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color fg \).*/\1$FG;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color accent \).*/\1$ACCENT;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color black \).*/\1$BLACK;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color blue \).*/\1$BLUE;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color cyan \).*/\1$CYAN;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color green \).*/\1$GREEN;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color magenta \).*/\1$MAGENTA;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color red \).*/\1$RED;/" "$HOME/.config/waybar/theme.css"
# sed -i "s/\(@define-color yellow \).*/\1$YELLOW;/" "$HOME/.config/waybar/theme.css"

# ------------------------------------------------------------------------------
# Rofi
# ------------------------------------------------------------------------------
# sed -i "s/\(background-primary:[[:space:]]*\).*/\1$BG;/" "$HOME/.config/rofi/theme.rasi"
# sed -i "s/\(window-border:[[:space:]]*\).*/\1$ACCENT;/" "$HOME/.config/rofi/theme.rasi"
# sed -i "s/\(text:[[:space:]]*\).*/\1$FG;/" "$HOME/.config/rofi/theme.rasi"
# sed -i "s/\(text-secondary:[[:space:]]*\).*/\1$FG_SECONDARY;/" "$HOME/.config/rofi/theme.rasi"

# ------------------------------------------------------------------------------
# Dunst
# ------------------------------------------------------------------------------
# sed -i "s/\(background[[:space:]]*=[[:space:]]*\).*/\1\"$BG\"/" "$HOME/.config/dunst/dunstrc"
# sed -i "s/\(foreground[[:space:]]*=[[:space:]]*\).*/\1\"$FG\"/" "$HOME/.config/dunst/dunstrc"
# sed -i "s/\(frame_color[[:space:]]*=[[:space:]]*\).*/\1\"$ACCENT\"/" "$HOME/.config/dunst/dunstrc"

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------
sed -i "s/\(colorscheme[[:space:]]*=[[:space:]]*\"\).*/\1$NVIM_SCHEME\",/" \
  "$HOME/.config/nvim/lua/plugins/colorscheme.lua"

# ------------------------------------------------------------------------------
# Alacritty
# ------------------------------------------------------------------------------
sed -i "s/\(import[[:space:]]*=[[:space:]]*\[\"[.\/]*themes\/\).*/\1$ALACRITTY_THEME\"\]/" \
  "$HOME/.config/alacritty/alacritty.toml"

# ------------------------------------------------------------------------------
# Sway
# ------------------------------------------------------------------------------
sed -i "s/\(set \$color_accent[[:space:]]\+\).*/\1$ACCENT/" \
  "$HOME/.config/sway/config"

sed -i "s/\(set \$color_accent_active[[:space:]]\+\).*/\1$ACCENT_ACTIVE/" \
  "$HOME/.config/sway/config"

# ------------------------------------------------------------------------------
# Wallpaper
# ------------------------------------------------------------------------------
sed -i \
  "s|^\(output \* bg \)[^[:space:]]*\( .*$\)|\1~/Pictures/wallpapers/$WALLPAPER\2|" \
  "$HOME/.config/sway/config"

# ------------------------------------------------------------------------------
# System Theme Toggle (Light/Dark)
# ------------------------------------------------------------------------------
if [ -n "$SYSTEM_THEME" ]; then
  SYS_SCRIPT="$HOME/.config/sway/scripts/system_theme.sh"
  if [ -f "$SYS_SCRIPT" ]; then
    bash "$SYS_SCRIPT" "$SYSTEM_THEME"
  else
    echo "Warning: System theme script not found at $SYS_SCRIPT"
  fi
fi

# ------------------------------------------------------------------------------
# Reload
# ------------------------------------------------------------------------------
if [ -f "$HOME/.config/sway/scripts/reload.sh" ]; then
  bash "$HOME/.config/sway/scripts/reload.sh"
fi

echo "Theme '$THEME' successfully applied!"
