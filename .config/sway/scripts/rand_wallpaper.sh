#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWAY_CONFIG="$HOME/.config/sway/config"

# 1. Grab a random file, filtering only known image types
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

if [[ ${#WALLS[@]} -eq 0 ]]; then
  echo "No wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

NEXT_WALL="${WALLS[RANDOM % ${#WALLS[@]}]}"

# 2. Update the Sway config
sed -i "s|^\(output \* bg \).*\( fill\)$|\1$NEXT_WALL\2|" "$SWAY_CONFIG"

# 3. Reload immediately
swaymsg "output * bg '$NEXT_WALL' fill"
