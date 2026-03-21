#!/bin/bash
# ===================================================================
# Unified theme and wallpaper switcher for Hyprland setup
# Usage: theme_change.sh <theme> <wallpaper1> <wallpaper2> <dark|light> [<nvim_theme>]
# Example: theme_change.sh solarized-osaka 028.jpg 010.jpg dark everforest
# ===================================================================

# === Configuration ===
SCRIPTS="$HOME/.config/hypr/scripts"
WALLDIR="$HOME/Pictures/wallpapers"

# === Input validation ===
if [ $# -lt 4 ]; then
  echo "Usage: $0 <theme> <wallpaper1> <wallpaper2> <dark|light> [<nvim_theme>]"
  exit 1
fi

THEME="$1"
WALL1="$2"
WALL2="$3"
MODE="$4"
NVIM_THEME="${5:-$THEME}" # Default to $THEME if not provided

# Validate mode
if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
  echo "❌ Invalid mode: '$MODE'. Must be 'dark' or 'light'."
  exit 1
fi

# === Apply themes ===
echo "🎨 Applying desktop theme: $THEME ($MODE mode)"
echo "🖼️  Wallpapers: $WALL1 (main), $WALL2 (others)"
echo "📝 Neovim theme: $NVIM_THEME"

# Waybar
#bash "$SCRIPTS/waybar_theme.sh" "$THEME"

# Alacritty
bash "$SCRIPTS/alacritty_theme.sh" "$THEME"

# SwayNC
#bash "$SCRIPTS/swaync_theme.sh" "$THEME"

# Neovim
bash "$SCRIPTS/nvim_theme.sh" "$NVIM_THEME"

# Wallpaper
bash "$SCRIPTS/wallpaper_change.sh" "$WALL1" "$WALL2"

# Wlogout
#bash "$SCRIPTS/wlogout_theme.sh" "$THEME"

# Hyprland
bash "$SCRIPTS/hyprland_theme.sh" "$THEME"

# Rofi
#bash "$SCRIPTS/rofi_theme.sh" "$THEME"

# === GTK / QT Color Settings ===
QT5_CONF="$HOME/.config/qt5ct/qt5ct.conf"
QT6_CONF="$HOME/.config/qt6ct/qt6ct.conf"

if [ "$MODE" = "dark" ]; then
  # GNOME theming
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

  # Qt theming
  sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/darker.conf|" "$QT5_CONF" "$QT6_CONF"
  sed -i "s|^icon_theme=.*|icon_theme=breeze-dark|" "$QT5_CONF" "$QT6_CONF"
else
  # GNOME theming
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'

  # Qt theming
  sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/simple.conf|" "$QT5_CONF" "$QT6_CONF"
  sed -i "s|^icon_theme=.*|icon_theme=breeze|" "$QT5_CONF" "$QT6_CONF"
fi

# === Reload Config ===
pkill hyprpaper
hyprpaper &

#bash "$SCRIPTS/reload.sh"

# === Done ===
echo "✅ Theme successfully applied!"
echo "   Desktop Theme: $THEME"
echo "   Wallpapers: $WALL1 / $WALL2"
echo "   Mode: $MODE"
echo "   Neovim Theme: $NVIM_THEME"
