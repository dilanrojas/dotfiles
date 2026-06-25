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

# If no argument was provided, determine current mode and toggle
if [ -z "$1" ]; then
  CURRENT=$(grep '^custom_palette=' "$QT_CONFIG" | cut -d= -f2)

  if [ "$CURRENT" = "true" ]; then
    MODE="light"
  else
    MODE="dark"
  fi

  echo "No mode specified. Toggling to $MODE..."
else
  MODE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
fi

case "$MODE" in
dark)
  echo "Switching to DARK mode..."

  sed -i 's/^custom_palette=.*/custom_palette=true/' "$QT_CONFIG"

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
  ;;

light)
  echo "Switching to LIGHT mode..."

  sed -i 's/^custom_palette=.*/custom_palette=false/' "$QT_CONFIG"

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
  ;;

*)
  echo "Invalid option: '$1'. Please use 'light' or 'dark'." >&2
  exit 1
  ;;
esac

echo "Theme adjustment complete!"
