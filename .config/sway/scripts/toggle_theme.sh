#!/bin/bash

# Define paths and theme names
QT_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"
GTK_LIGHT="adw-gtk3"
GTK_DARK="adw-gtk3-dark"

# Ensure the config file exists before proceeding
if [ ! -f "$QT_CONFIG" ]; then
  echo "Error: $QT_CONFIG not found." >&2
  exit 1
fi

# 1. Check the current state of custom_palette
# This grabs the value after the '=' for custom_palette
CURRENT_STATE=$(grep -E '^custom_palette=' "$QT_CONFIG" | cut -d'=' -f2 | tr -d '[:space:]')

# 2. Toggle based on the current state
if [ "$CURRENT_STATE" = "false" ]; then
  echo "Switching to DARK mode..."

  # Update qt6ct.conf: set custom_palette=true
  sed -i 's/^custom_palette=false/custom_palette=true/' "$QT_CONFIG"

  # Update GTK themes using gsettings
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"

else
  echo "Switching to LIGHT mode..."

  # Update qt6ct.conf: set custom_palette=false
  sed -i 's/^custom_palette=true/custom_palette=false/' "$QT_CONFIG"

  # Update GTK themes using gsettings
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
fi

echo "Theme toggle complete!"
