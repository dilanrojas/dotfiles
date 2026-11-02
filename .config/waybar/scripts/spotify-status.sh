#!/usr/bin/env bash
PLAYER="spotify"
SEP=$'\x1f'

trap 'pkill -P $$' EXIT
trap 'exit' TERM INT HUP

JQ_PROG='
def dflt($d): if . == "" then $d else . end;
def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
split("\u001f") as [$status, $title, $artist, $album]
| if $status == "Playing" or $status == "Paused" then
    ($title | dflt("Unknown Title")) as $t
    | ($artist | dflt("Unknown Artist")) as $a
    | ($album | dflt("Unknown Album")) as $b
    | {
        text: "\($t | esc) - \($a | esc) ",
        alt: ($status | ascii_downcase),
        tooltip: "<b>\($t | esc)</b> - \($a | esc). <i>\($b | esc)</i>"
      }
  else
    {text: "", alt: "idle"}
  end'

echo '{"text":"","alt":"idle"}'

while true; do
  playerctl --player "$PLAYER" metadata --follow \
    --format "{{status}}${SEP}{{xesam:title}}${SEP}{{xesam:artist}}${SEP}{{xesam:album}}" 2>/dev/null |
    awk '$0 != prev { print; fflush(); prev = $0 }' |
    jq --unbuffered -Rc "$JQ_PROG" &
  wait $!
  echo '{"text":"","alt":"idle"}'
  sleep 2
done
