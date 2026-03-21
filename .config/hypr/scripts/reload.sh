#!/bin/sh
hyprctl reload

systemctl stop --user waybar
systemctl start --user waybar

pkill hyprpaper
hyprpaper &

pkill swaync
swaync &

systemctl stop --user hypridle
systemctl start --user hypridle
