#!/bin/bash
# Usage: nvim_theme.sh <theme-name>
# Example: nvim_theme.sh kanagawa-wave

CONF="$HOME/.config/nvim/lua/plugins/colorscheme.lua"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace colorscheme line in the Lua config
sed -i "s|\(colorscheme = \"\)[^\"]*\(\"\)|\1${THEME}\2|" "$CONF"

echo "✅ Neovim theme changed to: $THEME"
