#!/usr/bin/env bash
# rofi.sh — generic rofi dmenu wrapper.
#
# Auto-sizes the listview to the number of items (capped at -l, default 7),
# so you stop hardcoding `lines`/`height`. Reads entries from stdin, prints
# the chosen entry to stdout (display-only; the caller acts on the result).
#
# Usage:
#   ... | rofi.sh [-p PROMPT] [-w WIDTH] [-l MAXLINES] [-I] [-L]
#
#   -p PROMPT    rofi prompt text
#   -w WIDTH     window width (e.g. 280px); left to the caller (hardcoded per script)
#   -l MAXLINES  max listview lines (default 7); lines = min(count, MAXLINES)
#   -I           enable icons (-show-icons); default is -no-show-icons
#   -L           label::command mode — strip everything after "::" for display,
#                print only the chosen label (so the caller maps it back to a command)
set -euo pipefail

prompt=""
width=""
max_lines=7
icons=0
label_mode=0

while getopts ":p:w:l:IL" opt; do
  case "$opt" in
    p) prompt="$OPTARG" ;;
    w) width="$OPTARG" ;;
    l) max_lines="$OPTARG" ;;
    I) icons=1 ;;
    L) label_mode=1 ;;
    *) ;;
  esac
done

mapfile -t entries < /dev/stdin
count=${#entries[@]}
lines=$(( count < max_lines ? count : max_lines ))
(( lines < 1 )) && lines=1

if (( label_mode )); then
  display=()
  for line in "${entries[@]}"; do
    [[ -z "$line" ]] && continue
    display+=("${line%%::*}")
  done
  entries=("${display[@]}")
fi

theme="listview { lines: ${lines}; }"
[[ -n "$width" ]] && theme="window { width: ${width}; } ${theme}"

args=(-dmenu -i)
(( icons )) && args+=(-show-icons) || args+=(-no-show-icons)
[[ -n "$prompt" ]] && args+=(-p "$prompt")

printf '%s\n' "${entries[@]}" | rofi "${args[@]}" -theme-str "$theme"
