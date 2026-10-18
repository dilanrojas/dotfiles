#!/usr/bin/env bash
# toggle_smart_gaps.sh — switch between the "gaps off" look (gaps 0, no border,
# dim_inactive + shadow on, smart-gap rules active, "round only floating"
# window rule active) and the "gaps on" look (gaps 5/10, border 2, dim/shadow
# off, both of those blocks commented out).
# Both looks' values live in ~/.config/hypr/gaps_state (seeded on first run and
# hand-editable); turning gaps on snapshots the current look there, so toggling
# back restores exactly what was there before — no external files needed.
# Border colors, rounding, dim_strength, animations and blur are never touched.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [on|off]" >&2
  echo "  on   - enable gaps (gaps 5/10, border 2)"
  echo "  off  - disable gaps (restore the saved look)"
  echo "  (no argument) - toggle"
  exit 1
}

MODE_ARG=""

if [[ $# -gt 1 ]]; then
  usage
elif [[ $# -eq 1 ]]; then
  case "$1" in
  on | off)
    MODE_ARG="$1"
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "Invalid argument: $1" >&2
    usage
    ;;
  esac
fi

LOOKS_FILE="$HOME/.config/hypr/config/looks.lua"
RULES_FILE="$HOME/.config/hypr/config/rules.lua"
STATE_FILE="$HOME/.config/hypr/gaps_state"
STATE_HEADER="# State for toggle_smart_gaps.sh — edit the values, then toggle."

[[ -f "$LOOKS_FILE" ]] || {
  echo "Missing file: $LOOKS_FILE" >&2
  exit 1
}
[[ -f "$RULES_FILE" ]] || {
  echo "Missing file: $RULES_FILE" >&2
  exit 1
}

# Seed the state file on first run. The OFF_* defaults are only a bootstrap
# placeholder — the real off-look is snapshotted when gaps are turned on.
if [[ ! -f "$STATE_FILE" ]]; then
  {
    echo "$STATE_HEADER"
    cat <<'EOF'
ON_GAPS_IN=5
ON_GAPS_OUT=10
ON_BORDER_SIZE=2
ON_DIM_INACTIVE=false
ON_SHADOW_ENABLED=false
OFF_GAPS_IN=0
OFF_GAPS_OUT=0
OFF_BORDER_SIZE=0
OFF_DIM_INACTIVE=true
OFF_SHADOW_ENABLED=true
EOF
  } >"$STATE_FILE"
  echo "Created $STATE_FILE with default values"
fi

# shellcheck source=/dev/null
source "$STATE_FILE"

for name in ON_GAPS_IN ON_GAPS_OUT ON_BORDER_SIZE OFF_GAPS_IN OFF_GAPS_OUT OFF_BORDER_SIZE; do
  [[ "${!name:-}" =~ ^[0-9]+$ ]] || {
    echo "Invalid $name in $STATE_FILE (expected a number)" >&2
    exit 1
  }
done
for name in ON_DIM_INACTIVE ON_SHADOW_ENABLED OFF_DIM_INACTIVE OFF_SHADOW_ENABLED; do
  [[ "${!name:-}" =~ ^(true|false)$ ]] || {
    echo "Invalid $name in $STATE_FILE (expected true or false)" >&2
    exit 1
  }
done

# block_val FILE INDENT BLOCK KEY — value of "KEY = value," inside "BLOCK = {"
# at the given tab-indent level, so nested blocks and repeated keys (enabled)
# never bleed into each other.
block_val() {
  awk -v ind="$2" -v block="$3" -v key="$4" '
    BEGIN { for (i = 0; i < ind; i++) t = t "\t"; nt = t "\t" }
    !inside && $0 ~ "^" t block " = \\{" { inside = 1; next }
    inside && $0 ~ "^" t "\\}," { inside = 0; next }
    inside && $0 ~ "^" nt key " = " {
      v = $0
      sub("^" nt key " = ", "", v)
      sub(/,[[:space:]]*$/, "", v)
      print v
      exit
    }
  ' "$1"
}

# Detect the current look from the smart-gap rules: uncommented == gaps off.
if grep -q '^hl\.workspace_rule({ workspace = "w\[tv1\]"' "$LOOKS_FILE"; then
  CURRENTLY_OFF=true
else
  CURRENTLY_OFF=false
fi

if [[ -z "$MODE_ARG" ]]; then
  if [[ "$CURRENTLY_OFF" == true ]]; then
    MODE_ARG="on"
  else
    MODE_ARG="off"
  fi
fi

TMP="$LOOKS_FILE.tmp"
TMP_RULES="$RULES_FILE.tmp"
TMP_STATE="$STATE_FILE.tmp"
trap 'rm -f "$TMP" "$TMP_RULES" "$TMP_STATE"' EXIT

# Entering gaps-on from gaps-off: snapshot the live values into OFF_* so
# toggling back restores this machine's actual previous look.
if [[ "$MODE_ARG" == "on" && "$CURRENTLY_OFF" == true ]]; then
  CUR_GAPS_IN="$(block_val "$LOOKS_FILE" 1 general gaps_in)"
  CUR_GAPS_OUT="$(block_val "$LOOKS_FILE" 1 general gaps_out)"
  CUR_BORDER_SIZE="$(block_val "$LOOKS_FILE" 1 general border_size)"
  CUR_DIM_INACTIVE="$(block_val "$LOOKS_FILE" 1 decoration dim_inactive)"
  CUR_SHADOW_ENABLED="$(block_val "$LOOKS_FILE" 2 shadow enabled)"

  [[ "$CUR_GAPS_IN" =~ ^[0-9]+$ && "$CUR_GAPS_OUT" =~ ^[0-9]+$ && "$CUR_BORDER_SIZE" =~ ^[0-9]+$ ]] || {
    echo "Could not read current gaps/border values from $LOOKS_FILE" >&2
    exit 1
  }
  [[ "$CUR_DIM_INACTIVE" =~ ^(true|false)$ && "$CUR_SHADOW_ENABLED" =~ ^(true|false)$ ]] || {
    echo "Could not read current dim/shadow values from $LOOKS_FILE" >&2
    exit 1
  }

  {
    echo "$STATE_HEADER"
    echo "ON_GAPS_IN=$ON_GAPS_IN"
    echo "ON_GAPS_OUT=$ON_GAPS_OUT"
    echo "ON_BORDER_SIZE=$ON_BORDER_SIZE"
    echo "ON_DIM_INACTIVE=$ON_DIM_INACTIVE"
    echo "ON_SHADOW_ENABLED=$ON_SHADOW_ENABLED"
    echo "OFF_GAPS_IN=$CUR_GAPS_IN"
    echo "OFF_GAPS_OUT=$CUR_GAPS_OUT"
    echo "OFF_BORDER_SIZE=$CUR_BORDER_SIZE"
    echo "OFF_DIM_INACTIVE=$CUR_DIM_INACTIVE"
    echo "OFF_SHADOW_ENABLED=$CUR_SHADOW_ENABLED"
  } >"$TMP_STATE"
  chmod --reference="$STATE_FILE" "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
  echo "Saved current look to $STATE_FILE"
fi

if [[ "$MODE_ARG" == "on" ]]; then
  GAPS_IN="$ON_GAPS_IN"
  GAPS_OUT="$ON_GAPS_OUT"
  BORDER_SIZE="$ON_BORDER_SIZE"
  DIM_INACTIVE="$ON_DIM_INACTIVE"
  SHADOW_ENABLED="$ON_SHADOW_ENABLED"
else
  GAPS_IN="$OFF_GAPS_IN"
  GAPS_OUT="$OFF_GAPS_OUT"
  BORDER_SIZE="$OFF_BORDER_SIZE"
  DIM_INACTIVE="$OFF_DIM_INACTIVE"
  SHADOW_ENABLED="$OFF_SHADOW_ENABLED"
fi

# Apply the values inside their blocks and (un)comment the smart-gap rules in a
# single pass. The END check fails the run if the file doesn't match the
# expected layout, so the config is never left half-edited.
if ! awk \
  -v gaps_in="$GAPS_IN" \
  -v gaps_out="$GAPS_OUT" \
  -v border_size="$BORDER_SIZE" \
  -v dim_inactive="$DIM_INACTIVE" \
  -v shadow_enabled="$SHADOW_ENABLED" \
  -v target="$MODE_ARG" '
  BEGIN { i1 = "\t"; i2 = "\t\t"; i3 = "\t\t\t" }

  # general = { gaps_in, gaps_out, border_size }
  !in_general && $0 ~ "^" i1 "general = \\{" { in_general = 1 }
  in_general && $0 ~ "^" i1 "\\}," { in_general = 0 }
  in_general && $0 ~ "^" i2 "gaps_in = " {
    print i2 "gaps_in = " gaps_in ","; ok_gaps_in = 1; next
  }
  in_general && $0 ~ "^" i2 "gaps_out = " {
    print i2 "gaps_out = " gaps_out ","; ok_gaps_out = 1; next
  }
  in_general && $0 ~ "^" i2 "border_size = " {
    print i2 "border_size = " border_size ","; ok_border = 1; next
  }

  # decoration = { dim_inactive, shadow = { enabled } }
  !in_dec && $0 ~ "^" i1 "decoration = \\{" { in_dec = 1 }
  in_dec && $0 ~ "^" i1 "\\}," { in_dec = 0 }
  in_dec && $0 ~ "^" i2 "shadow = \\{" { in_shadow = 1 }
  in_shadow && $0 ~ "^" i2 "\\}," { in_shadow = 0 }
  in_shadow && $0 ~ "^" i3 "enabled = " {
    print i3 "enabled = " shadow_enabled ","; ok_shadow = 1; next
  }
  in_dec && $0 ~ "^" i2 "dim_inactive = " {
    print i2 "dim_inactive = " dim_inactive ","; ok_dim = 1; next
  }

  # Smart gaps rules: comment out ("on") or uncomment ("off") the block that
  # sits between the "-- Smart gaps" marker and the "-- Default animations"
  # comment. Empty lines and already-commented lines are left alone, so the
  # commented result matches the usual formatting exactly.
  $0 ~ "^-- Smart gaps[[:space:]]*$" { in_smart = 1; seen_smart = 1 }
  in_smart && $0 ~ "^-- Default animations" { in_smart = 0 }
  in_smart && target == "on" && $0 != "" && $0 !~ "^--[[:space:]]" {
    print "-- " $0
    next
  }
  in_smart && target == "off" && $0 ~ "^-- " &&
    $0 !~ "^-- Smart gaps[[:space:]]*$" && $0 !~ "^-- Default animations" {
    sub(/^-- /, "")
    print
    next
  }

  { print }

  END {
    if (!(ok_gaps_in && ok_gaps_out && ok_border && ok_dim && ok_shadow && seen_smart)) exit 42
  }
' "$LOOKS_FILE" >"$TMP"; then
  echo "Failed to update $LOOKS_FILE: unexpected layout (nothing changed)" >&2
  exit 1
fi

# rules.lua: the "round only floating" window rule belongs to the gaps-off
# look, so it gets commented out with gaps on and restored with gaps off. The
# block is buffered (top-level "hl.window_rule({" ... "})"), so one already in
# the target state is left untouched.
if ! awk -v target="$MODE_ARG" '
  /^(-- )?hl\.window_rule\(\{[[:space:]]*$/ { in_rule = 1; buf_n = 0 }
  in_rule {
    buf[++buf_n] = $0
    if ($0 ~ /^(-- )?\}\)[[:space:]]*$/) {
      is_target = 0
      for (i = 1; i <= buf_n; i++)
        if (buf[i] ~ /name = "round only floating"/) is_target = 1
      if (is_target) seen = 1
      for (i = 1; i <= buf_n; i++) {
        if (is_target && target == "on" && buf[i] != "" && buf[i] !~ /^--[[:space:]]/) {
          print "-- " buf[i]
        } else if (is_target && target == "off" && buf[i] ~ /^-- /) {
          line = buf[i]
          sub(/^-- /, "", line)
          print line
        } else {
          print buf[i]
        }
      }
      in_rule = 0
    }
    next
  }
  { print }
  END { if (!seen) exit 43 }
' "$RULES_FILE" >"$TMP_RULES"; then
  echo "Failed to update $RULES_FILE: 'round only floating' rule not found (nothing changed)" >&2
  exit 1
fi

# Commit both files only after every pass succeeded.
chmod --reference="$LOOKS_FILE" "$TMP"
mv "$TMP" "$LOOKS_FILE"
chmod --reference="$RULES_FILE" "$TMP_RULES"
mv "$TMP_RULES" "$RULES_FILE"
trap - EXIT

hyprctl reload || echo "Warning: hyprctl reload failed (not running under Hyprland?)" >&2

if [[ "$MODE_ARG" == "on" ]]; then
  echo "Gaps enabled (gaps ${GAPS_IN}/${GAPS_OUT}, border ${BORDER_SIZE})"
else
  echo "Gaps disabled (restored gaps ${GAPS_IN}/${GAPS_OUT}, border ${BORDER_SIZE})"
fi

echo "Done."
