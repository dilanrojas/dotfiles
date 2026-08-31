#!/usr/bin/env bash
# themes/lib.sh — shared theme application logic for hypr_theme.sh / toggle_effects.sh
# Source this file; it expects THEMES_DIR / CURRENT_THEME_FILE to be set (they are, below).

: "${XDG_CONFIG_HOME:=$HOME/.config}"
HYPR_DIR="$XDG_CONFIG_HOME/hypr"
THEMES_DIR="$HYPR_DIR/themes"
CURRENT_THEME_FILE="$THEMES_DIR/current_theme"

ROFI_ACTIVE="$XDG_CONFIG_HOME/rofi/active_theme.rasi"
WAYBAR_THEME="$XDG_CONFIG_HOME/waybar/theme.css"
SWAYOSD_THEME="$XDG_CONFIG_HOME/swayosd/theme.css"
ALACRITTY_CONF="$XDG_CONFIG_HOME/alacritty/alacritty.toml"
ALACRITTY_ACTIVE="$XDG_CONFIG_HOME/alacritty/active_theme.toml"
DUNST_CONF="$XDG_CONFIG_HOME/dunst/dunstrc"
LOOKS_FILE="$HYPR_DIR/config/looks.lua"
HYPRPAPER_CONF="$HYPR_DIR/hyprpaper.conf"
NVIM_COLORSCHEME="$XDG_CONFIG_HOME/nvim/lua/plugins/colorscheme.lua"

# ---- current theme state ----
CUR_THEME=""
CUR_SYSTEM="dark"
CUR_EFFECTS="ON"

load_current() {
  if [ -f "$CURRENT_THEME_FILE" ]; then
    while IFS='=' read -r k v; do
      case "$k" in
      THEME) CUR_THEME="$v" ;;
      SYSTEM_THEME) CUR_SYSTEM="$v" ;;
      EFFECTS) CUR_EFFECTS="$v" ;;
      esac
    done <"$CURRENT_THEME_FILE"
  fi
}

write_current() {
  cat >"$CURRENT_THEME_FILE" <<EOF
THEME=$CUR_THEME
SYSTEM_THEME=$CUR_SYSTEM
EFFECTS=$CUR_EFFECTS
EOF
}

# ---- per-theme config (config.json) ----
CFG_WALLPAPER=""
CFG_NVIM=""
CFG_SYSTEM="dark"
CFG_OPACITY="0.92"
CFG_ICONS=""
CFG_ACTIVE=""
CFG_INACTIVE=""

read_cfg() {
  local key="$1" f="$THEMES_DIR/$1/config.json"
  [ -f "$f" ] || return 1
  CFG_WALLPAPER=$(jq -r '.wallpaper' "$f")
  CFG_NVIM=$(jq -r '.neovim_scheme' "$f")
  CFG_SYSTEM=$(jq -r '.system_theme // "dark"' "$f")
  CFG_OPACITY=$(jq -r '.opacity // 0.92' "$f")
  CFG_ICONS=$(jq -r '.icons // ""' "$f")
  CFG_ACTIVE=$(jq -r '.palette.active' "$f")
  CFG_INACTIVE=$(jq -r '.palette.inactive' "$f")
  return 0
}

# ---- alpha helpers ----
ALPHA_CSS="1.0"
ALPHA_HEX="ff"

compute_alpha() {
  local op="$CFG_OPACITY"
  if [ "$CUR_EFFECTS" = "OFF" ]; then op="1.0"; fi
  ALPHA_CSS="$op"
  ALPHA_HEX=$(awk -v o="$op" 'BEGIN { printf "%02x", int(o * 255 + 0.5) }')
}

# ---- generators (write live copies from theme source) ----
gen_rofi() {
  local key="$1" src="$THEMES_DIR/$1/rofi.rasi"
  # Bake the window alpha into the `bg` and `bg-darker` colors themselves
  # (e.g. `bg: #00141a;` -> `bg: #00141ad9;` when effects are on, `...ff;` off).
  # No separate `bg-opacity` key: the color carries its own opacity, so the
  # panel is transparent with effects on and fully opaque with them off.
  awk -v a="$ALPHA_HEX" '
    /^[[:space:]]*(bg|bg-darker)[[:space:]]*:/ {
      m = match($0, /#[0-9A-Fa-f]{6}/)
      $0 = substr($0, 1, m - 1) "#" substr($0, m + 1, 6) a substr($0, m + 7)
    }
    { print }
  ' "$src" >"$ROFI_ACTIVE"
}

gen_waybar() {
  local key="$1" src="$THEMES_DIR/$1/waybar.css"
  awk -v a="$ALPHA_CSS" '{
    if ($0 ~ /^@define-color bg /) {
      split($0, p, "#")
      gsub(/;.*/, "", p[2])
      printf "@define-color bg alpha(#%s, %s);\n", p[2], a
    } else { print }
  }' "$src" >"$WAYBAR_THEME"
}

gen_swayosd() {
  local key="$1" src="$THEMES_DIR/$1/swayosd.css"
  awk -v a="$ALPHA_CSS" '{
    if ($0 ~ /^@define-color bg /) {
      split($0, p, "#")
      gsub(/;.*/, "", p[2])
      printf "@define-color bg alpha(#%s, %s);\n", p[2], a
    } else { print }
  }' "$src" >"$SWAYOSD_THEME"
}

gen_alacritty() {
  cp "$THEMES_DIR/$1/alacritty.toml" "$ALACRITTY_ACTIVE"
}

apply_dunst() {
  local key="$1" src="$THEMES_DIR/$1/dunstrc"
  local bg fg frame
  bg=$(awk -F'"' '/background =/{print $2}' "$src")
  bg="${bg#\#}"
  fg=$(awk -F'"' '/foreground =/{print $2}' "$src")
  frame=$(awk -F'"' '/frame_color =/{print $2}' "$src")
  frame="${frame#\#}"
  sed -i -E "s/^([[:space:]]*)background[[:space:]]*=[[:space:]]*.*/\1background = \"#${bg}${ALPHA_HEX}\"/" "$DUNST_CONF"
  sed -i -E "s/^([[:space:]]*)foreground[[:space:]]*=[[:space:]]*.*/\1foreground = \"${fg}\"/" "$DUNST_CONF"
  sed -i -E "s/^([[:space:]]*)frame_color[[:space:]]*=[[:space:]]*.*/\1frame_color = \"#${frame}\"/" "$DUNST_CONF"
}

apply_looks() {
  local ah ih
  ah="${CFG_ACTIVE#\#}"
  ih="${CFG_INACTIVE#\#}"
  sed -i -E "/^[[:space:]]*active_border/s/rgba\([0-9a-fA-F]{6,8}\)/rgba(${ah}ff)/" "$LOOKS_FILE"
  sed -i -E "/inactive_border/s/rgba\([0-9a-fA-F]{6,8}\)/rgba(${ih}ff)/" "$LOOKS_FILE"
}

apply_alacritty_opacity() {
  sed -i "s/^\(opacity[[:space:]]*=[[:space:]]*\).*/\1$ALPHA_CSS/" "$ALACRITTY_CONF"
}

apply_nvim() {
  # Persist the active theme as colorscheme.lua so the next nvim launch applies
  # it (all themes are pre-installed via themes.lua, so this is just a snippet
  # copy - no Lazy install). Then live-switch any running instance via socket.
  cp "$THEMES_DIR/$1/nvim.lua" "$NVIM_COLORSCHEME"
  local rt="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  local sock
  # Match both Neovim socket layouts: legacy flat (nvim.<pid>.0) and the nested
  # layout used by recent Neovim (nvim/<pid>/0).
  for sock in "$rt"/nvim*.0 "$rt"/nvim/*/0; do
    [ -S "$sock" ] || continue
    # Use --remote-expr (not --remote-send) so the switch happens silently,
    # without the command line briefly flashing ":" in front of you.
    nvim --server "$sock" --remote-expr "execute('colorscheme $CFG_NVIM') . execute('set background=$CFG_SYSTEM')" 2>/dev/null
  done
}

apply_wallpaper() {
  local key="$1" wp="$THEMES_DIR/$1/wallpapers/$CFG_WALLPAPER"
  [ -f "$wp" ] || return 0
  hyprctl hyprpaper unload all 2>/dev/null
  hyprctl hyprpaper preload "$wp" 2>/dev/null
  hyprctl hyprpaper wallpaper ",$wp" 2>/dev/null
  sed -i "s|^\([[:space:]]*path[[:space:]]*=[[:space:]]*\).*|\1~/.config/hypr/themes/$key/wallpapers/$CFG_WALLPAPER|" "$HYPRPAPER_CONF"
}

apply_icons() {
  [ -n "$CFG_ICONS" ] && gsettings set org.gnome.desktop.interface icon-theme "$CFG_ICONS" 2>/dev/null
}

apply_system_theme() {
  local sys="$CFG_SYSTEM"
  [ -n "$sys" ] && bash "$HYPR_DIR/scripts/system_theme.sh" "$sys" 2>/dev/null
}

# ---- high level ----
apply_theme() {
  local key="$1"
  CUR_THEME="$key"
  read_cfg "$key" || {
    echo "Theme '$key' not found"
    return 1
  }
  compute_alpha
  CUR_SYSTEM="$CFG_SYSTEM"
  gen_alacritty "$key"
  gen_rofi "$key"
  gen_waybar "$key"
  gen_swayosd "$key"
  apply_dunst "$key"
  apply_looks "$key"
  apply_alacritty_opacity
  apply_nvim "$key"
  apply_wallpaper "$key"
  apply_icons
  apply_system_theme
  write_current
}

# regenerate only the alpha-dependent live files (used by toggle_effects)
apply_opacity() {
  local key="$CUR_THEME"
  [ -n "$key" ] || return 1
  read_cfg "$key" || return 1
  compute_alpha
  gen_rofi "$key"
  gen_waybar "$key"
  gen_swayosd "$key"
  apply_dunst "$key"
  apply_alacritty_opacity
}
