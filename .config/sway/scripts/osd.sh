#!/usr/bin/env bash
#
# osd.sh — volume / brightness / mic / playerctl controller with swayosd
#
# Usage:
#   osd.sh volume      increase|decrease|toggle-mute
#   osd.sh brightness  increase|decrease
#   osd.sh mic         increase|decrease|toggle-mute
#   osd.sh playerctl   play-pause|next|previous|stop

set -euo pipefail

ACTION="${1:-}"
VALUE="${2:-}"

usage() {
  echo "Usage: $(basename "$0") <volume|brightness|mic|playerctl> <value>"
  echo
  echo "  volume      increase | decrease | toggle-mute"
  echo "  brightness  increase | decrease"
  echo "  mic         increase | decrease | toggle-mute"
  echo "  playerctl   play-pause | next | previous | stop"
  exit 1
}

[[ -z "$ACTION" || -z "$VALUE" ]] && usage

# Focused monitor, used so the OSD pops up on the right screen
MONITOR=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true).name')

osd() {
  swayosd-client --monitor "$MONITOR" "$@"
}

volume() {
  case "$VALUE" in
  increase) osd --output-volume raise ;;
  decrease) osd --output-volume lower ;;
  toggle-mute) osd --output-volume mute-toggle ;;
  *) usage ;;
  esac
}

brightness() {
  case "$VALUE" in
  increase) osd --brightness raise ;;
  decrease) osd --brightness lower ;;
  *) usage ;;
  esac
}

mic() {
  case "$VALUE" in
  increase) osd --input-volume raise ;;
  decrease) osd --input-volume lower ;;
  toggle-mute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    osd --input-volume raise
    ;;
  *) usage ;;
  esac
}

playerctl_action() {
  case "$VALUE" in
  play-pause | next | previous | stop | play | pause) command playerctl "$VALUE" ;;
  *) usage ;;
  esac
}

case "$ACTION" in
volume) volume ;;
brightness) brightness ;;
mic) mic ;;
playerctl) playerctl_action ;;
*) usage ;;
esac
