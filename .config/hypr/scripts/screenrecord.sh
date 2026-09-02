#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="$HOME/Videos/Recordings"
mkdir -p "$OUTPUT_DIR"

STATUS_FILE="/tmp/screenrecording.status"
WAYBAR_SIGNAL=9

notify() {
  notify-send -a "Screen Recorder" "$@"
}

screenrecording_active() {
  pgrep -f "^gpu-screen-recorder" >/dev/null
}

refresh_waybar() {
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

focused_monitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

start_recording() {
  local audio_mode="${1:-desktop}"

  # If a recording is somehow already running, treat this as a stop instead of
  # spawning a second instance on top of it.
  if screenrecording_active; then
    stop_recording
    return
  fi

  local audio_devices="default_output"
  local audio_args=()
  case "$audio_mode" in
  mic) audio_devices+="|default_input" ;&
  desktop) audio_args=(-a "$audio_devices" -ac aac) ;;
  none) audio_args=() ;;
  esac

  local monitor
  monitor="$(focused_monitor)"
  [[ -z "$monitor" ]] && {
    notify -u critical "Could not find focused monitor"
    exit 1
  }

  local filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"

  # High quality: native resolution, 60fps CFR, auto codec with CPU fallback.
  gpu-screen-recorder -w "$monitor" -k auto -f 60 -fm cfr -fallback-cpu-encoding yes \
    -o "$filename" "${audio_args[@]}" &

  local pid=$!
  while kill -0 "$pid" 2>/dev/null && [[ ! -f "$filename" ]]; do
    sleep 0.2
  done

  if kill -0 "$pid" 2>/dev/null; then
    echo "active:$(date +%s)" >"$STATUS_FILE"
    refresh_waybar
  else
    notify -u critical "Recording failed to start"
  fi
}

stop_recording() {
  if ! screenrecording_active; then
    rm -f "$STATUS_FILE"
    refresh_waybar
    return
  fi

  pkill -SIGINT -f "^gpu-screen-recorder" # SIGINT required to save the file

  local count=0
  while pgrep -f "^gpu-screen-recorder" >/dev/null && ((count < 50)); do
    sleep 0.1
    count=$((count + 1))
  done

  rm -f "$STATUS_FILE"
  # Signal waybar immediately so the indicator clears even though the
  # notification (dunstify -A) blocks. Previously refresh_waybar was after
  # dunstify, so the module stayed "recording" until the notification
  # timed out / was dismissed. The interval:1 poll is also re-triggered on
  # click (exec-on-event:true) before rm, so without an early signal the next
  # poll still saw the old state.
  refresh_waybar

  if pgrep -f "^gpu-screen-recorder" >/dev/null; then
    pkill -9 -f "^gpu-screen-recorder"
    notify -u critical "Recording force-killed" "The video may be corrupted"
  else
    # Detach the blocking action-notification from the waybar on-click child.
    # Waybar forkExec tracks the on-click pid; if we block here waybar's next
    # exec is delayed until dunstify returns (notification timeout). Background
    # with setsid so killing the on-click cgroup doesn't kill dunstify, and the
    # script can exit immediately after the refresh above.
    setsid bash -c '
      OUTPUT_DIR="$HOME/Videos/Recordings"
      shopt -s nullglob
      files=("$OUTPUT_DIR"/screenrecording-*.mp4)
      shopt -u nullglob
      filename=""
      if ((${#files[@]})); then
        filename="$(printf "%s\n" "${files[@]}" | sort -r | head -1)"
      fi
      base="$(basename "${filename:-screenrecording}")"
      action="$(dunstify -a "Screen Recorder" -A open,Open "Screen recording saved" "$base" 2>/dev/null || true)"
      if [[ "$action" == "open" && -n "$filename" ]]; then
        xdg-open "$filename" &>/dev/null &
      fi
    ' &>/dev/null &
    disown || true
  fi
}

pick_audio_and_start() {
  local options=$'  Desktop audio\n  Desktop audio + microphone\n  No audio'
  local choice
  choice="$(echo "$options" | "$(dirname "${BASH_SOURCE[0]}")/rofi.sh" -p "Screen Recorder")" || exit 0
  [[ -z "$choice" ]] && exit 0

  case "$choice" in
  *"microphone"*) start_recording "mic" ;;
  *"No audio"*) start_recording "none" ;;
  *) start_recording "desktop" ;;
  esac
}

case "${1:-}" in
stop) stop_recording ;;
start)
  shift
  audio_mode="desktop"
  for arg in "$@"; do
    case "$arg" in
    --with-mic) audio_mode="mic" ;;
    --no-audio) audio_mode="none" ;;
    esac
  done
  start_recording "$audio_mode"
  ;;
"")
  if screenrecording_active; then
    stop_recording
  else
    pick_audio_and_start
  fi
  ;;
*)
  echo "Usage: $0 [start [--with-mic|--no-audio] | stop]" >&2
  exit 1
  ;;
esac
