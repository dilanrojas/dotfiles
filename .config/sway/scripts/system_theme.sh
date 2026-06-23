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

# Check for required argument
if [ -z "$1" ]; then
  echo "Usage: $0 {light|dark}" >&2
  exit 1
fi

# Convert argument to lowercase
MODE=$(echo "$1" | tr '[:upper:]' '[:lower:]')

case "$MODE" in
"dark")
  echo "Switching to DARK mode..."

  # Update qt6ct.conf: set custom_palette=true
  sed -i 's/^custom_palette=.*/custom_palette=true/' "$QT_CONFIG"

  # Update GTK themes using gsettings
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
  ;;

"light")
  echo "Switching to LIGHT mode..."

  # Update qt6ct.conf: set custom_palette=false
  sed -i 's/^custom_palette=.*/custom_palette=false/' "$QT_CONFIG"

  # Update GTK themes using gsettings
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
  ;;

*)
  echo "Invalid option: '$1'. Please use 'light' or 'dark'." >&2
  exit 1
  ;;
esac

echo "Theme adjustment complete!"
