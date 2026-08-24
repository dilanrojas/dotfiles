#!/usr/bin/env bash

JSON_FILE="$HOME/.config/hypr/themes.json"
CURRENT_THEME_FILE="$HOME/.config/hypr/current_theme"
LOOKS_FILE="$HOME/.config/hypr/config/looks.lua"
WALLPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
  echo "Error: $JSON_FILE not found."
  exit 1
fi

# If no theme argument is provided, prompt with Rofi
if [ -z "$1" ]; then
  MENU_ITEMS=""

  while IFS=$'\t' read -r key label; do
    icon="$HOME/.config/hypr/wallpapers/$key/arch.jpg"
    MENU_ITEMS+="${key}\t${label}\x00icon\x1f${icon}\n"
  done < <(jq -r '
    [ to_entries[]
      | select(.key != "default-dark" and .key != "default-light") ]
    | sort_by(.key)[]
    | "\(.key)\t\(.value.label)"
  ' "$JSON_FILE")

  # Strip the trailing newline so rofi doesn't show an empty last entry
  MENU_ITEMS="${MENU_ITEMS%\\n}"

  THEME=$(
    echo -e "$MENU_ITEMS" | rofi -dmenu -i -p "Select Theme" -display-columns 2 \
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
      ' |
      cut -f1
  )

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
ICON_THEME=$(jq -r --arg theme "$THEME" '.[$theme].icons // "Yaru-blue-dark"' "$JSON_FILE")

# Extract Shared palette (used for nvim/alacritty-adjacent apps, e.g. sway accents)
ACCENT=$(jq -r --arg theme "$THEME" '.[$theme].palette.active' "$JSON_FILE")

# Border colors: active = full accent, inactive = dimmed accent
ACCENT_INACTIVE=$(jq -r --arg theme "$THEME" '.[$theme].palette.inactive' "$JSON_FILE")

# Extract default light/dark palette (used for waybar/rofi/dunst) based on SYSTEM_THEME
DEFAULT_KEY="default-${SYSTEM_THEME}"
BG_DEFAULT=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].palette.bg' "$JSON_FILE")
BG_DEFAULT_SECONDARY=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].palette.bg_secondary' "$JSON_FILE")
BG_DEFAULT_TERTIARY=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].palette.bg_tertiary' "$JSON_FILE")
BG_DEFAULT_LIGHTER=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].palette.bg_lighter' "$JSON_FILE")
FG_DEFAULT=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].palette.fg' "$JSON_FILE")

if [ "$BG_DEFAULT" = "null" ] || [ -z "$BG_DEFAULT" ]; then
  echo "Warning: '$DEFAULT_KEY' not found or incomplete in $JSON_FILE, falling back to theme palette."
  BG_DEFAULT="$BG"
  BG_DEFAULT_SECONDARY="$BG"
  BG_DEFAULT_TERTIARY="$BG"
  BG_DEFAULT_LIGHTER="$BG"
  FG_DEFAULT="$FG"
fi

# ------------------------------------------------------------------------------
# Opacity (per-theme, falling back to default-dark/default-light, then 0.9)
# ------------------------------------------------------------------------------
OPACITY=$(jq -r --arg theme "$THEME" '.[$theme].opacity // empty' "$JSON_FILE")

if [ -z "$OPACITY" ]; then
  OPACITY=$(jq -r --arg key "$DEFAULT_KEY" '.[$key].opacity // empty' "$JSON_FILE")
fi

if [ -z "$OPACITY" ]; then
  OPACITY="0.9"
  echo "Warning: no opacity set for '$THEME' or '$DEFAULT_KEY', defaulting to $OPACITY"
fi

# ------------------------------------------------------------------------------
# Effects (transparency) — read prior persisted state before we overwrite it
# ------------------------------------------------------------------------------
EFFECTS="ON"
if [ -f "$CURRENT_THEME_FILE" ]; then
  PREV_EFFECTS=$(awk -F= '/^EFFECTS=/{print $2}' "$CURRENT_THEME_FILE")
  [ -n "$PREV_EFFECTS" ] && EFFECTS="$PREV_EFFECTS"
fi

# THEME_OPACITY = the theme's declared/intrinsic opacity (persisted as-is).
# APPLY_OPACITY = what actually gets written into configs right now,
# which depends on whether effects are currently toggled off.
THEME_OPACITY="$OPACITY"
if [ "$EFFECTS" = "OFF" ]; then
  APPLY_OPACITY="1.0"
else
  APPLY_OPACITY="$THEME_OPACITY"
fi

# Decimal opacity, used as-is by alacritty and CSS alpha() functions
ALPHA_CSS="$APPLY_OPACITY"
ALPHA_TER="$APPLY_OPACITY"

# Hex alpha (00-ff), used by rofi/dunst hex-suffixed colors, rounded to nearest int
ALPHA=$(awk -v o="$APPLY_OPACITY" 'BEGIN { printf "%02x", int(o * 255 + 0.5) }')

eval "$(
  awk '
    /^\[colors\.primary\]/ { in_primary=1; in_normal=0; next }
    
    /^\[colors\.normal\]/ { in_normal=1; in_primary=0; next }
    
    /^\[/ { in_primary=0; in_normal=0 }
    
    in_primary && /^(background|foreground)[[:space:]]*=/ {
      split($0, a, "=")
      gsub(/[[:space:]\047]/, "", a[1])
      gsub(/[[:space:]\047]/, "", a[2])
      
      var_name = (a[1] == "background") ? "BG" : "FG"
      print var_name "=" a[2]
    }
    
    in_normal && /^[a-z]+[[:space:]]*=/ {
      split($0, a, "=")
      gsub(/[[:space:]\047]/, "", a[1])
      gsub(/[[:space:]\047]/, "", a[2])
      print toupper(a[1]) "=" a[2]
    }
  ' "$HOME/.config/alacritty/themes/${ALACRITTY_THEME}"
)"

ACCENT_HEX="${ACCENT#\#}"
ACCENT_INACTIVE_HEX="${ACCENT_INACTIVE#\#}"

# Store the current theme
cat >"$CURRENT_THEME_FILE" <<EOF
THEME=$THEME
SYSTEM_THEME=$SYSTEM_THEME
BG=${BG#\#}
OPACITY=$THEME_OPACITY
EFFECTS=$EFFECTS
EOF

# ------------------------------------------------------------------------------
# Waybar
# ------------------------------------------------------------------------------
sed -i "s/\(@define-color bg \).*/\1alpha(${BG}, ${ALPHA_CSS});/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color fg \).*/\1$FG;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color accent \).*/\1$ACCENT;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color black \).*/\1$BLACK;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color blue \).*/\1$BLUE;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color cyan \).*/\1$CYAN;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color green \).*/\1$GREEN;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color magenta \).*/\1$MAGENTA;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color red \).*/\1$RED;/" "$HOME/.config/waybar/theme.css"
sed -i "s/\(@define-color yellow \).*/\1$YELLOW;/" "$HOME/.config/waybar/theme.css"

# ------------------------------------------------------------------------------
# Rofi
# ------------------------------------------------------------------------------
sed -i "s/\(bg-primary:[[:space:]]*\).*/\1$BG;/" "$HOME/.config/rofi/theme.rasi"
sed -i "s/\(bg-primary-opacity:[[:space:]]*\).*/\1$BG$ALPHA;/" "$HOME/.config/rofi/theme.rasi"
sed -i "s/\(bg-secondary:[[:space:]]*\).*/\1$BLACK;/" "$HOME/.config/rofi/theme.rasi"
sed -i "s/\(accent:[[:space:]]*\).*/\1$ACCENT;/" "$HOME/.config/rofi/theme.rasi"
sed -i "s/\(fg:[[:space:]]*\).*/\1$FG;/" "$HOME/.config/rofi/theme.rasi"

# ------------------------------------------------------------------------------
# Dunst
# ------------------------------------------------------------------------------
sed -i "s/\(background[[:space:]]*=[[:space:]]*\).*/\1\"$BG$ALPHA\"/" "$HOME/.config/dunst/dunstrc"
sed -i "s/\(foreground[[:space:]]*=[[:space:]]*\).*/\1\"$FG\"/" "$HOME/.config/dunst/dunstrc"
sed -i "s/\(frame_color[[:space:]]*=[[:space:]]*\).*/\1\"$FG\"/" "$HOME/.config/dunst/dunstrc"

# ------------------------------------------------------------------------------
# Neovim
# ------------------------------------------------------------------------------
sed -i "s/\(colorscheme[[:space:]]*=[[:space:]]*\"\).*/\1$NVIM_SCHEME\",/" \
  "$HOME/.config/nvim/lua/plugins/colorscheme.lua"

# 2. Update all *running* Neovim windows immediately via sockets
for socket in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim*.0; do
  if [ -S "$socket" ]; then
    nvim --server "$socket" --remote-send "<cmd>colorscheme $NVIM_SCHEME<cr>"
    nvim --server "$socket" --remote-send "<cmd>set background=$SYSTEM_THEME<cr>"
  fi
done

# ------------------------------------------------------------------------------
# Alacritty
# ------------------------------------------------------------------------------
sed -i "s/^\(opacity[[:space:]]*=[[:space:]]*\).*/\1$ALPHA_TER/" "$HOME/.config/alacritty/alacritty.toml"

sed -i "s/\(import[[:space:]]*=[[:space:]]*\[\"[.\/]*themes\/\).*/\1$ALACRITTY_THEME\"\]/" \
  "$HOME/.config/alacritty/alacritty.toml"

# ------------------------------------------------------------------------------
# Hyprland
# ------------------------------------------------------------------------------
sed -i -E "/^[[:space:]]*active_border/s/rgba\([0-9a-fA-F]{6,8}\)/rgba(${ACCENT_HEX}ff)/" "$LOOKS_FILE"
sed -i -E "/inactive_border/s/rgba\([0-9a-fA-F]{6,8}\)/rgba(${ACCENT_INACTIVE_HEX}ff)/" "$LOOKS_FILE"

# ------------------------------------------------------------------------------
# SwayOSD
# ------------------------------------------------------------------------------
sed -i "s/\(@define-color bg \).*/\1$BG;/" "$HOME/.config/swayosd/theme.css"
sed -i "s/\(@define-color border \).*/\1$ACCENT;/" "$HOME/.config/swayosd/theme.css"
sed -i "s/\(@define-color segment \).*/\1$BG_DEFAULT_LIGHTER;/" "$HOME/.config/swayosd/theme.css"
sed -i "s/\(@define-color progress \).*/\1$FG;/" "$HOME/.config/swayosd/theme.css"

# ------------------------------------------------------------------------------
# Wallpaper
# ------------------------------------------------------------------------------
WALLPAPER_PATH="$HOME/.config/hypr/wallpapers/$THEME/$WALLPAPER"

# Drop the old preloaded image so we don't leak memory across switches
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER_PATH"
hyprctl hyprpaper wallpaper ",$WALLPAPER_PATH"

# Keep the conf file in sync so a fresh hyprpaper start also picks it up
sed -i "s|^\([[:space:]]*path[[:space:]]*=[[:space:]]*\).*|\1~/.config/hypr/wallpapers/$THEME/$WALLPAPER|" \
  "$WALLPAPER_CONF"

# ------------------------------------------------------------------------------
# System Theme Toggle (Light/Dark)
# ------------------------------------------------------------------------------
if [ -n "$SYSTEM_THEME" ]; then
  SYS_SCRIPT="$HOME/.config/hypr/scripts/system_theme.sh"
  if [ -f "$SYS_SCRIPT" ]; then
    bash "$SYS_SCRIPT" "$SYSTEM_THEME"
  else
    echo "Warning: System theme script not found at $SYS_SCRIPT"
  fi
fi

# ------------------------------------------------------------------------------
# Icon Theme
# ------------------------------------------------------------------------------
if [ -n "$ICON_THEME" ]; then
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
fi

# ------------------------------------------------------------------------------
# Reload
# ------------------------------------------------------------------------------
# if [ -f "$HOME/.config/hypr/scripts/reload.sh" ]; then
#   bash "$HOME/.config/hypr/scripts/reload.sh"
# fi

pkill dunst

pkill swayosd-server
swayosd-server &

# notify-send -t 1500 -i /usr/share/icons/Papirus/48x48/apps/gnome-settings-theme.svg "Sway Theme" "Now using $THEME!"
