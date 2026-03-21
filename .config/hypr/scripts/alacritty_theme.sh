#!/bin/bash
# Usage: alacritty_theme.sh <theme-name>
# Example: alacritty_theme.sh kanagawa-wave

CONF="$HOME/.config/alacritty/alacritty.toml"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the import path
sed -i "s|\(import = \[\"~/.config/hypr/themes/\)\([^/]*\)\(/alacritty\.toml\"]\)|\1${THEME}\3|" "$CONF"

echo "✅ Alacritty theme changed to: $THEME"
