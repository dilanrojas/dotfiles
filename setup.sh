#!/usr/bin/env bash
#
# install.sh — Sway Dotfiles installer
#
# Interactive installer that mirrors the README. It pauses and asks for
# explicit confirmation before anything risky or irreversible (disk flags,
# overwriting existing configs, changing the login shell, etc).
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

c_reset="\033[0m"
c_bold="\033[1m"
c_green="\033[1;32m"
c_yellow="\033[1;33m"
c_red="\033[1;31m"
c_blue="\033[1;34m"

log() { echo -e "${c_blue}==>${c_reset} ${c_bold}$*${c_reset}"; }
ok() { echo -e "${c_green}✔${c_reset} $*"; }
warn() { echo -e "${c_yellow}⚠${c_reset} $*"; }
err() { echo -e "${c_red}✘${c_reset} $*" >&2; }

# ask_yes_no "Question" [default: y|n]
ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local hint="y/N"
  [[ "$default" == "y" ]] && hint="Y/n"
  local reply
  read -r -p "$(echo -e "${c_yellow}?${c_reset} ${prompt} [${hint}]: ")" reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^([yY][eE][sS]|[yY])$ ]]
}

# ask_typed_confirmation "Question" "REQUIRED_WORD"
# Used for destructive/irreversible steps — requires typing an exact phrase.
ask_typed_confirmation() {
  local prompt="$1"
  local required="$2"
  local reply
  warn "$prompt"
  read -r -p "$(echo -e "  Type '${c_bold}${required}${c_reset}' to proceed, or anything else to skip: ")" reply
  [[ "$reply" == "$required" ]]
}

run() {
  echo -e "  ${c_bold}\$${c_reset} $*"
  "$@"
}

section() {
  echo
  echo -e "${c_bold}────────────────────────────────────────────────────${c_reset}"
  echo -e "${c_bold}$*${c_reset}"
  echo -e "${c_bold}────────────────────────────────────────────────────${c_reset}"
}

require_not_root() {
  if [[ "$EUID" -eq 0 ]]; then
    err "Don't run this script as root. It calls sudo itself when needed."
    exit 1
  fi
}

require_not_root

log "Sway Dotfiles installer"
echo "This script walks through the steps in the README. Every step that"
echo "installs packages, overwrites files, or touches disk partitions will"
echo "ask for confirmation first — nothing destructive runs silently."
echo
if ! ask_yes_no "Ready to begin?" "y"; then
  echo "Aborted."
  exit 0
fi

# ---------------------------------------------------------------------------
# 1. AUR helper (yay)
# ---------------------------------------------------------------------------
section "1. AUR Helper (yay)"

if command -v yay >/dev/null 2>&1; then
  ok "yay is already installed, skipping."
else
  if ask_yes_no "Install yay (AUR helper)?" "y"; then
    tmpdir="$(mktemp -d)"
    run git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && run makepkg -rsi)
    rm -rf "$tmpdir"
    ok "yay installed."
  else
    warn "Skipping yay. AUR packages later in this script will fail without it."
  fi
fi

# ---------------------------------------------------------------------------
# 2. Mirrors
# ---------------------------------------------------------------------------
section "2. Configure Pacman Mirrors"

if ask_yes_no "Rank and update your pacman mirrorlist with rate-mirrors? (overwrites /etc/pacman.d/mirrorlist)" "n"; then
  run yay -S --noconfirm rate-mirrors-bin
  run bash -c "rate-mirrors --allow-root --protocol https arch | grep -v '#' | sudo tee /etc/pacman.d/mirrorlist"
  ok "Mirrorlist updated."
else
  warn "Skipping mirror ranking."
fi

# ---------------------------------------------------------------------------
# 3. Core packages
# ---------------------------------------------------------------------------
section "3. Core Sway/Desktop Packages"

if ask_yes_no "Install swayfx + swaylock-effects (AUR)?" "y"; then
  run yay -S --noconfirm swayfx swaylock-effects
fi

if ask_yes_no "Install core desktop environment packages (fonts, GNOME apps, UI tools)?" "y"; then
  run sudo pacman -S --needed sway-contrib swaybg swayidle swayosd wmname sddm hyprpicker qt6ct \
    qt5ct waybar nwg-look nwg-displays adw-gtk-theme polkit-gnome xdg-desktop-portal-wlr \
    xdg-desktop-portal-gtk alacritty fish starship lsd bat nautilus gnome-disk-utility loupe \
    showtime gnome-text-editor gnome-calendar gnome-clocks gnome-calculator papers grim slurp \
    cliphist neovim nano brightnessctl pamixer ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd \
    ttf-iosevkaterm-nerd woff2-font-awesome noto-fonts-emoji dconf-editor kcolorchooser \
    libsecret ruby nodejs npm ripgrep fd fzf luarocks gcc lazygit git udiskie udisks2 \
    libappindicator unzip unrar wget curl mlocate fastfetch python-pipx gnome-keyring seahorse \
    ksshaskpass ttf-opensans breeze dunst libnotify rofi wireless-regdb playerctl \
    papirus-icon-theme jq parted fwupd fwupd-efi gnome-firmware wlsunset gvfs-mtp
fi

if ask_yes_no "Install LibreOffice?" "y"; then
  run sudo pacman -S libreoffice-still libreoffice-still-es ttf-caladea ttf-carlito \
    ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji adobe-source-code-pro-fonts \
    adobe-source-sans-fonts adobe-source-serif-fonts hunspell hunspell-es_cr \
    hunspell-en_us hyphen hyphen-en hyphen-es libmythes mythes-en mythes-es \
    hunspell-en_gb hunspell-es_any
fi

if ask_yes_no "Install extra fonts & basic apps (brave-bin, wlogout, etc. — AUR)?" "y"; then
  run yay -S --noconfirm ttf-plemoljp-bin waybar-module-pacman-updates-git wlogout brave-bin \
    ttf-ms-fonts downgrade wayfreeze lswt appimagelauncher wlctl-bin
fi

if ask_yes_no "Install rich-cli via pipx (for viewing markdown in the terminal)?" "y"; then
  run pipx install rich-cli
fi

# ---------------------------------------------------------------------------
# 4. Audio & connectivity
# ---------------------------------------------------------------------------
section "4. Audio & Connectivity"

if ask_yes_no "Install audio/Bluetooth/printing packages (pipewire, bluez, cups, ...)?" "y"; then
  run sudo pacman -S --needed pipewire pipewire-pulse pipewire-alsa alsa-utils pavucontrol \
    pipewire-jack wireplumber bluez bluez-utils bluetui cups cups-pdf
fi

if ask_yes_no "Install media codecs (gst-plugins, x264/x265)?" "y"; then
  run sudo pacman -S --needed gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad \
    gst-plugins-ugly x265 x264
fi

# ---------------------------------------------------------------------------
# 5. Graphics drivers
# ---------------------------------------------------------------------------
section "5. Graphics Drivers"

echo "Pick your GPU vendor so the right driver packages are installed."
echo "  1) Intel"
echo "  2) AMD"
echo "  3) NVIDIA"
echo "  4) Skip graphics driver install"
read -r -p "$(echo -e "${c_yellow}?${c_reset} Choice [4]: ")" gpu_choice
gpu_choice="${gpu_choice:-4}"

case "$gpu_choice" in
1)
  run sudo pacman -S --needed xorg xorg-server libva libva-intel-driver intel-media-driver \
    mesa vulkan-intel vulkan-icd-loader vulkan-headers vulkan-devel vulkan-mesa-layers \
    opencl-mesa vulkan-mesa-implicit-layers
  ;;
2)
  run sudo pacman -S --needed xorg xorg-server libva libva-mesa-driver mesa vulkan-radeon \
    vulkan-icd-loader vulkan-headers vulkan-devel vulkan-mesa-layers opencl-mesa \
    vulkan-mesa-implicit-layers
  ;;
3)
  run sudo pacman -S --needed xorg xorg-server nvidia nvidia-utils vulkan-icd-loader \
    vulkan-headers vulkan-devel
  ;;
*)
  warn "Skipping graphics driver install."
  ;;
esac

# ---------------------------------------------------------------------------
# 6. zram
# ---------------------------------------------------------------------------
section "6. zram (compressed swap in RAM)"

if ask_yes_no "Set up zram-generator?" "n"; then
  run sudo pacman -S --needed zram-generator
  if [[ -f "$SCRIPT_DIR/dotfiles/zram-generator.conf" ]]; then
    if [[ -f /etc/systemd/zram-generator.conf ]] && ! ask_yes_no "  /etc/systemd/zram-generator.conf already exists. Overwrite it?" "n"; then
      warn "  Skipping zram config copy."
    else
      run sudo cp "$SCRIPT_DIR/dotfiles/zram-generator.conf" /etc/systemd/
    fi
    run sudo systemctl enable --now systemd-zram-setup@zram0.service
    ok "zram enabled."
  else
    err "  dotfiles/zram-generator.conf not found next to this script — skipping."
  fi
fi

# ---------------------------------------------------------------------------
# 7. Enable core services
# ---------------------------------------------------------------------------
section "7. Enable Services"

if ask_yes_no "Enable sddm, bluetooth, cups, fwupd system services?" "y"; then
  run sudo systemctl enable sddm bluetooth cups fwupd
fi

if ask_yes_no "Enable pipewire audio services for your user?" "y"; then
  run systemctl --user enable --now pipewire pipewire-pulse wireplumber
fi

# ---------------------------------------------------------------------------
# 8. Deploy dotfiles
# ---------------------------------------------------------------------------
section "8. Deploy Dotfiles"

if [[ -d "$SCRIPT_DIR/dotfiles/.config" || -d "$SCRIPT_DIR/dotfiles/.local" ]]; then
  if [[ -d "$HOME/.config" ]]; then
    warn "This will copy over files in \$HOME/.config and \$HOME/.local, which may"
    warn "overwrite existing configs of the same name."
  fi
  if ask_yes_no "Copy dotfiles/.config and dotfiles/.local into \$HOME?" "y"; then
    [[ -d "$SCRIPT_DIR/dotfiles/.config" ]] && run cp -r "$SCRIPT_DIR/dotfiles/.config" "$HOME/"
    [[ -d "$SCRIPT_DIR/dotfiles/.local" ]] && run cp -r "$SCRIPT_DIR/dotfiles/.local" "$HOME/"
    ok "Dotfiles copied."
  fi
else
  warn "No dotfiles/.config or dotfiles/.local found next to this script — skipping copy."
fi

if ask_yes_no "Clone the wallpaper collection into ~/Pictures/wallpapers?" "y"; then
  if [[ -d "$HOME/Pictures/wallpapers" ]]; then
    warn "~/Pictures/wallpapers already exists — skipping clone."
  else
    run git clone https://github.com/dilanrojas/wallpapers.git "$HOME/Pictures/wallpapers"
  fi
fi

if ask_yes_no "Set fish as the default shell for your user and root?" "n"; then
  run sudo usermod --shell /usr/bin/fish "$USER"
  if ask_yes_no "  Also set fish as root's shell?" "n"; then
    run sudo usermod --shell /usr/bin/fish root
  fi
fi

if ask_yes_no "Configure git to use libsecret for stored credentials?" "y"; then
  run git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
fi

if ask_yes_no "Run xdg-user-dirs-update and sudo updatedb?" "y"; then
  run xdg-user-dirs-update
  run sudo updatedb
fi

# ---------------------------------------------------------------------------
# 9. Boot / ESP partition flags — DESTRUCTIVE, extra confirmation required
# ---------------------------------------------------------------------------
section "9. Boot / ESP Partition Flags"

echo "This step edits partition flags with parted. Getting the wrong disk or"
echo "partition number can make your system unbootable. Skip this if you are"
echo "not sure, or if your boot/ESP flags are already set correctly."
echo

if ask_yes_no "Do you want to review/set boot+esp flags on a partition now?" "n"; then
  log "Available disks:"
  lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E 'disk$' || true
  echo
  read -r -p "$(echo -e "${c_yellow}?${c_reset} Disk device (e.g. nvme0n1, sda) — no /dev/ prefix: ")" disk_name
  disk="/dev/${disk_name}"

  if [[ ! -b "$disk" ]]; then
    err "  $disk is not a valid block device. Skipping this step."
  else
    log "Current partition table for $disk:"
    run sudo parted "$disk" print
    echo
    read -r -p "$(echo -e "${c_yellow}?${c_reset} Partition number to flag as boot+esp (e.g. 1): ")" part_num

    if ask_typed_confirmation \
      "About to run: parted $disk set $part_num boot on / esp on. This changes partition flags on $disk, partition $part_num." \
      "SET FLAGS"; then
      run sudo parted "$disk" set "$part_num" boot on
      run sudo parted "$disk" set "$part_num" esp on
      log "Updated partition table:"
      run sudo parted "$disk" print
      ok "Boot/ESP flags set. Double-check the output above before rebooting."
    else
      warn "  Skipped — no changes made to $disk."
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 10. Battery tools (laptops)
# ---------------------------------------------------------------------------
section "10. Battery Tools (Laptops)"

if ask_yes_no "Is this a laptop? Install power-profiles-daemon?" "n"; then
  run sudo pacman -S --needed power-profiles-daemon
  run sudo systemctl enable --now power-profiles-daemon
  ok "power-profiles-daemon enabled."
fi

# ---------------------------------------------------------------------------
# 11. Waybar persistent workspaces
# ---------------------------------------------------------------------------
section "11. Waybar Persistent Workspaces"

if ask_yes_no "Look up your monitor names now (needed to edit Waybar's workspaces module)?" "n"; then
  if command -v swaymsg >/dev/null 2>&1; then
    run swaymsg -t get_outputs
  else
    warn "  swaymsg not found (Sway may not be running yet)."
  fi
  echo
  if ask_yes_no "  Open ~/.config/waybar/config.json in nvim now to edit it?" "n"; then
    ${EDITOR:-nvim} "$HOME/.config/waybar/config.json"
  else
    warn "  Remember to edit ~/.config/waybar/config.json manually later."
  fi
fi

# ---------------------------------------------------------------------------
# 12. SDDM Astronaut theme (optional, runs a remote script)
# ---------------------------------------------------------------------------
section "12. SDDM Astronaut Theme (Optional)"

warn "This downloads and runs a remote install script from GitHub with sudo."
if ask_yes_no "Review that risk and proceed with installing the SDDM Astronaut theme?" "n"; then
  run sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
else
  warn "Skipped. You can install it later — see the README."
fi

# ---------------------------------------------------------------------------
# 13. Font rendering (optional, runs a remote script as root)
# ---------------------------------------------------------------------------
section "13. Improve Font Rendering (Optional)"

warn "This clones lucidglyph and runs its install script with sudo."
if ask_yes_no "Install lucidglyph for improved font rendering?" "n"; then
  tmpdir="$(mktemp -d)"
  run git clone https://github.com/maximilionus/lucidglyph "$tmpdir/lucidglyph"
  (cd "$tmpdir/lucidglyph" && run sudo ./lucidglyph.sh install)
  rm -rf "$tmpdir"
  ok "lucidglyph installed. Run 'sudo ./lucidglyph.sh remove' from a fresh clone to undo."
else
  warn "Skipped."
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
section "Done"
ok "Setup steps complete. Reboot to fully apply shell, service, and boot changes."
