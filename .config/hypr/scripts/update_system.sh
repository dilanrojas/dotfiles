#!/usr/bin/env bash

update_system() {
  echo "Updating System Packages..."

  local start_time
  start_time=$(date +"%Y-%m-%d %H:%M")

  if ! sudo pacman -Sy --needed archlinux-keyring; then
    echo "Failed to update the keyring."
    return 1
  fi

  if sudo pacman -Syu; then
    if journalctl _COMM=pacman --since "$start_time" | grep -qE "upgraded linux(-lts|-zen|-hardened)? "; then
      echo -e "\n\033[1;33m[!] A kernel update was detected.\033[0m"
      read -r -p "Reboot now? [y/N] " response

      response=${response,,}
      if [[ "$response" =~ ^(yes|y)$ ]]; then
        echo "Rebooting system..."
        sudo reboot
      else
        echo "Remember to reboot later!"
      fi
    fi
  fi
}

update_aur() {
  echo "Updating AUR Packages..."
  if command -v yay &>/dev/null; then
    yay -Sua
  elif command -v paru &>/dev/null; then
    paru -Sua
  else
    echo "No AUR helper (yay/paru) found!"
  fi
}

update_flatpak() {
  echo "Updating Flatpak Packages..."
  if command -v flatpak &>/dev/null; then
    flatpak update -y
  else
    echo "Flatpak is not installed."
  fi
}

update_firmware() {
  echo "Updating Firmware..."
  if command -v fwupdmgr &>/dev/null; then
    fwupdmgr refresh && fwupdmgr update
  else
    echo "fwupdmgr is not installed."
  fi
}

# Define the menu options
OPTIONS="󰣇  Full System Upgrade
  System Packages
  AUR Packages
  Flatpak Packages
󱔼  Firmware Updates"

# Launch rofi and get user choice
CHOICE=$(echo -e "$OPTIONS" | rofi -no-show-icons -dmenu -i -p "Update Manager" -theme-str 'window { width: 330px; height: 353px; }')

# Exit if user cancels
[ -z "$CHOICE" ] && exit 0

# Open a terminal to execute the commands so you can see progress and enter passwords
# We use 'bash -c' and 'read' at the end to keep the window open when finished.
run_in_terminal() {
  alacritty --class float -e bash -c "$1; echo -e '\nDone! Press Enter to close.'; read"
  return 0
}

# Process the choice
case "$CHOICE" in
*Full*)
  CMD="update_system; echo; update_aur; echo; update_flatpak; echo; update_firmware"
  # Export functions so the new terminal shell can see them
  export -f update_system update_aur update_flatpak update_firmware
  run_in_terminal "$CMD"
  ;;
*System*)
  export -f update_system
  run_in_terminal "update_system"
  ;;
*AUR*)
  export -f update_aur
  run_in_terminal "update_aur"
  ;;
*Flatpak*)
  export -f update_flatpak
  run_in_terminal "update_flatpak"
  ;;
*Firmware*)
  export -f update_firmware
  run_in_terminal "update_firmware"
  ;;
esac
