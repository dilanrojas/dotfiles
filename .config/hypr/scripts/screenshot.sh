#!/usr/bin/env bash
set -euo pipefail

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

notify_and_edit() {
  local filepath="$1"
  local filename
  filename="$(basename "$filepath")"

  # -A implies --wait and prints the invoked action's name to stdout.
  # Run in background so this script returns immediately.
  (
    action="$(notify-send \
      -i "$filepath" \
      -a "grimblast" \
      -A "edit=Edit with Swappy" \
      "Screenshot saved" "You can paste the image from the clipboard")"
    if [[ "$action" == "edit" ]]; then
      # -o saves back to the same file/dir when the user hits Save;
      # if unmodified, swappy never touches it.
      swappy -f "$filepath" -o "$filepath"
    fi
  ) &
  disown
}

capture_screenshot() {
  local mode="$1"
  local filename
  filename="$(date +'%Y-%m-%d-%H%M%S')_grimblast.png"

  local target
  local flags=()

  case "$mode" in
  area)
    # Covers both "crop" (drag a region) and "window" (click a window) --
    # grimblast's slurp-based area selection handles both interactions.
    target="area"
    flags+=(--freeze)
    ;;
  active)
    target="active"
    ;;
  full)
    target="output"
    ;;
  *)
    exit 1
    ;;
  esac

  # grimblast handles saving + clipboard copy itself.
  # A non-zero exit (e.g. selection cancelled) just means nothing to do.
  if ! grimblast "${flags[@]}" copysave "$target" "$SAVE_DIR/$filename"; then
    exit 0
  fi

  notify_and_edit "$SAVE_DIR/$filename"
}

if [[ $# -gt 0 ]]; then
  case "$1" in
  crop) capture_screenshot area ;;
  window) capture_screenshot area ;;
  active) capture_screenshot active ;;
  full) capture_screenshot full ;;
  *)
    echo "Usage: $0 [crop|window|active|full]"
    exit 1
    ;;
  esac
else
  OPTIONS="󰆞  Crop Selection\n󰖯  Window Selection\n󰹑  Fullscreen\n󱂵  Active Window"
  CHOICE=$(echo -e "$OPTIONS" | rofi \
    -dmenu \
    -i \
    -no-show-icons \
    -p "Screenshot" \
    -theme-str 'window {width: 280px; height: 303px;}')
  [[ -z "$CHOICE" ]] && exit 0
  sleep 0.4
  case "$CHOICE" in
  *"Crop Selection"*) capture_screenshot area ;;
  *"Window Selection"*) capture_screenshot area ;;
  *"Fullscreen"*) capture_screenshot full ;;
  *"Active Window"*) capture_screenshot active ;;
  *) exit 0 ;;
  esac
fi
