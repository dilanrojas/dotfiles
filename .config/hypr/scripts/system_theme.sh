#!/usr/bin/env bash
# system_theme.sh — light/dark switch for Qt + GTK.
#
# Qt6:  qt6ct only parses its own color-scheme format, so the BreezeKDE
#       schemes are pre-converted (kcolorscheme2qt.py) into
#       ~/.config/qt6ct/colors/Breeze{Dark,Light}.conf and color_scheme_path is
#       flipped here. style=Breeze (breeze6.so) renders that palette.
#       Touching ~/.config/qt6ct makes RUNNING Qt apps re-read within ~3 s.
# GTK:  gsettings color-scheme + gtk-theme (virt-manager, GTK apps).
# Qt5:  Fusion style + same Breeze palettes (no breeze5 plugin installed).

CURRENT_THEME_FILE="$HOME/.config/hypr/themes/current_theme"
QT5_CONFIG="$HOME/.config/qt5ct/qt5ct.conf"
QT6_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"
QT5_COLORS="$HOME/.config/qt5ct/colors"
QT6_COLORS="$HOME/.config/qt6ct/colors"
CONVERTER="$HOME/.config/hypr/scripts/kcolorscheme2qt.py"
SRC_DARK="/usr/share/color-schemes/BreezeDark.colors"
SRC_LIGHT="/usr/share/color-schemes/BreezeLight.colors"

GTK_LIGHT="adw-gtk3"
GTK_DARK="adw-gtk3-dark"

ensure_schemes() {
    # regenerate if missing (fresh machine / colors dir wiped)
    if [ -f "$QT6_COLORS/BreezeDark.conf" ] && [ -f "$QT6_COLORS/BreezeLight.conf" ]; then
        return 0
    fi
    command -v python3 >/dev/null 2>&1 && [ -f "$CONVERTER" ] || return 0
    mkdir -p "$QT5_COLORS" "$QT6_COLORS"
    for d in "$QT6_COLORS" "$QT5_COLORS"; do
        python3 "$CONVERTER" "$SRC_DARK"  "$d/BreezeDark.conf"  >/dev/null
        python3 "$CONVERTER" "$SRC_LIGHT" "$d/BreezeLight.conf" >/dev/null
    done
}

# ---------------------------------------------------------------- mode selection
# With no argument: TOGGLE relative to the live state. The gsettings
# color-scheme value is what this script writes on every switch, so it is the
# reliable "current mode" signal. Fallbacks: qt6ct palette path, then
# themes/current_theme's SYSTEM_THEME.
MODE=""
if [ -n "${1:-}" ]; then
    MODE="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
else
    CUR=""
    if command -v gsettings >/dev/null 2>&1; then
        CUR=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
    fi
    case "$CUR" in
    prefer-dark) MODE="light" ;;
    prefer-light) MODE="dark" ;;
    default | "") MODE="" ;;
    esac
    if [ -z "$MODE" ]; then
        if grep -q 'colors/BreezeDark.conf' "$QT6_CONFIG" 2>/dev/null; then
            MODE="light"
        elif grep -q 'colors/BreezeLight.conf' "$QT6_CONFIG" 2>/dev/null; then
            MODE="dark"
        elif [ -f "$CURRENT_THEME_FILE" ]; then
            MODE=$(awk -F= '$1 == "SYSTEM_THEME" {print $2}' "$CURRENT_THEME_FILE" | head -1)
        fi
    fi
    MODE="${MODE:-dark}"
    echo "No mode specified. Toggling to $MODE..."
fi

ensure_schemes

case "$MODE" in
dark)
    echo "Switching to DARK mode..."
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT6_COLORS}/BreezeDark.conf|" "$QT6_CONFIG"
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT5_COLORS}/BreezeDark.conf|" "$QT5_CONFIG"
    sed -i 's/^icon_theme=.*/icon_theme=breeze-dark/' "$QT5_CONFIG" "$QT6_CONFIG"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
    ;;

light)
    echo "Switching to LIGHT mode..."
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT6_COLORS}/BreezeLight.conf|" "$QT6_CONFIG"
    sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT5_COLORS}/BreezeLight.conf|" "$QT5_CONFIG"
    sed -i 's/^icon_theme=.*/icon_theme=breeze/' "$QT5_CONFIG" "$QT6_CONFIG"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
    ;;

*)
    echo "Invalid option: '$1'. Please use 'light' or 'dark'." >&2
    exit 1
    ;;
esac

# Nudge live reload for running Qt6 apps (QFileSystemWatcher on the config dir)
touch "$HOME/.config/qt6ct" "$HOME/.config/qt5ct"

echo "Theme adjustment complete!"
