# Sway Dotfiles

A sleek, productive Sway environment with a focus on the GNOME/Adwaita ecosystem.

## Preview

<img src="./preview/image.png" alt="Dotfiles preview" />

## Index

- [Keybindings](#keybindings)
  - [Applications \& Utilities](#applications--utilities)
  - [Window Management \& Navigation](#window-management--navigation)
- [Themes](#themes)
- [Core Components](#-core-components)
- [List of Packages](#-list-of-packages)
  - [Sway \& Desktop](#-sway--desktop)
  - [Audio \& Connectivity](#-audio--connectivity)
  - [Xorg, Graphics \& Gaming](#-xorg-graphics--gaming)
  - [Setup zram](#setup-zram)
- [Installation \& Setup](#-installation--setup)
  - [1. Enable Services](#1-enable-services)
  - [2. Deploy Dotfiles](#2-deploy-dotfiles)
  - [Configure Boot/ESP Flags](#configure-bootesp-flags)
  - [Battery Tools (Laptops)](#battery-tools-useful-for-a-laptop)
  - [Configuring Persistent Workspaces in Waybar](#configuring-persistent-workspaces-in-waybar)
  - [3. SDDM \& Font Rendering (Optional)](#3-sddm--font-rendering-optional)
  - [Improve Font Rendering](#improve-font-rendering)

---

## Keybindings

The `SUPER` key (Windows key) is your primary modifier, referred to as `$mod` below.

### Applications & Utilities

| Keybind | Action |
| --- | --- |
| `$mod` + `Return` | Open Terminal |
| `$mod` + `q` | Kill active window |
| `$mod` + `m` | Open Menu (App Launcher) |
| `$mod` + `b` | Open Web Browser |
| `$mod` + `e` | Open File Manager |
| `$mod` + `p` | Open Colorpicker |
| `$mod` + `Shift` + `b` | Open Bluetooth Manager (`bluetui`) |
| `$mod` + `Shift` + `w` | Open Network Manager (`nmtui`) |
| `$mod` + `v` | Open Clipboard History |
| `$mod` + `n` | Toggle Do Not Disturb (`dnd`) |
| `$mod` + `Shift` + `p` | Change Power Profile |
| `$mod` + `t` | Change Sway Theme |
| `$mod` + `Shift` + `t` | Toggle System Theme (Dark/Light) |
| `$mod` + `Shift` + `m` | Launch Spotify (with adblock) |
| `$mod` + `r` | Change Random Wallpaper |
| `$mod` + `Shift` + `o` | Toggle Display Mirroring |
| `$mod` + `c` | Open Scripts Menu |
| `$mod` + `Shift` + `r` | Reload Sway Configuration |
| `$mod` + `Shift` + `q` | Open Logout Menu (`wlogout`) |
| `Print` | Take Screenshot |
| `$mod` + `s` | Take Screenshot (Crop / Selection) |

### Window Management & Navigation

| Keybind | Action |
| --- | --- |
| `$mod` + `Arrow` / `Vim Keys` | Focus Window (Left/Down/Up/Right) |
| `$mod` + `Shift` + `Arrow` / `Vim Keys` | Move Window (Left/Down/Up/Right) |
| `$mod` + `Control` + `Arrow` | Resize Active Window |
| `$mod` + `1` to `0` | Switch to Workspace 1–10 |
| `$mod` + `Shift` + `1` to `0` | Move Container to Workspace 1–10 |
| `$mod` + `f` | Toggle Fullscreen |
| `$mod` + `Shift` + `f` | Toggle Floating Mode |
| `$mod` + `space` | Switch Keyboard Layout |
| `$mod` + `u` | Show Scratchpad |
| `$mod` + `Shift` + `u` | Move Window to Scratchpad |

---

## Themes

Press `$mod` + `t` to open the Sway theme picker.

To add more themes:

1. Add an entry to `~/.config/sway/themes.json`.
2. Add a matching Alacritty theme in `~/.config/alacritty/themes`.
3. Add a matching Neovim theme in `~/.config/nvim/lua/plugins/themes.lua`.

---

## 🛠️ Core Components

| Component | Tool |
| --- | --- |
| Window Manager | [Sway](https://swaywm.org/) |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Shell | [Fish](https://fishshell.com/) with [Starship](https://starship.rs/) |
| Terminal | [Alacritty](https://alacritty.org/) |
| App Launcher | [Rofi](https://github.com/davatorium/rofi) |
| File Manager | [Nautilus](https://apps.gnome.org/en/Nautilus/) |
| Editor | [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/) |
| SDDM Theme | [SDDM Astronaut](https://github.com/Keyitdev/sddm-astronaut-theme) |
| Wallpapers | [My Collection](https://github.com/dilanrojas/wallpapers.git) |

---

## 📦 List of Packages

### ❄️ Sway & Desktop

**AUR Helper**

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -rsi
cd .. && rm -rf yay
```

**Configure mirrors**

```bash
yay -S rate-mirrors-bin --noconfirm

rate-mirrors --allow-root --protocol https arch | grep -v '#' | sudo tee /etc/pacman.d/mirrorlist
```

**Core environment** — fonts, UI tools, and GNOME apps:

```bash
yay -S swayfx swaylock-effects

sudo pacman -S sway-contrib swaybg swayidle swayosd wmname sddm hyprpicker qt6ct qt5ct waybar \
  nwg-look nwg-displays adw-gtk-theme polkit-gnome xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  alacritty fish starship lsd bat nautilus gnome-disk-utility loupe showtime gnome-text-editor \
  gnome-calendar gnome-clocks gnome-calculator papers grim slurp cliphist neovim nano \
  brightnessctl pamixer ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-iosevkaterm-nerd \
  woff2-font-awesome noto-fonts-emoji dconf-editor kcolorchooser libsecret ruby nodejs npm \
  ripgrep fd fzf luarocks gcc lazygit git udiskie udisks2 libappindicator unzip unrar wget curl \
  mlocate fastfetch python-pipx gnome-keyring seahorse libsecret ksshaskpass ttf-opensans breeze \
  dunst libnotify rofi wireless-regdb playerctl papirus-icon-theme jq parted fwupd fwupd-efi \
  gnome-firmware wlsunset gvfs-mtp
```


**LibreOffice Suite**

```bash
sudo pacman -S libreoffice-still libreoffice-still-es ttf-caladea ttf-carlito \
  ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji adobe-source-code-pro-fonts \
  adobe-source-sans-fonts adobe-source-serif-fonts hunspell hunspell-es_cr \
  hunspell-en_us hyphen hyphen-en hyphen-es libmythes mythes-en mythes-es \
  hunspell-en_gb hunspell-es_any
```

**Fonts & basic apps**

```bash
yay -S ttf-plemoljp-bin waybar-module-pacman-updates-git wlogout brave-bin ttf-ms-fonts \
  downgrade wayfreeze lswt appimagelauncher wlctl-bin --noconfirm
```

```bash
# A simple program for viewing markdown files on the command line
pipx install rich-cli
```

### 🎧 Audio & Connectivity

**Sound servers, Bluetooth, and printing**

```bash
sudo pacman -S pipewire pipewire-pulse pipewire-alsa alsa-utils pavucontrol pipewire-jack \
  wireplumber bluez bluez-utils bluetui cups cups-pdf
```

**Media codecs**

```bash
sudo pacman -S gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly x265 x264
```

### 🖥️ Xorg, Graphics & Gaming

Drivers and base display server components for hardware acceleration:

```bash
sudo pacman -S xorg xorg-server libva libva-intel-driver intel-media-driver mesa vulkan-intel \
  vulkan-icd-loader vulkan-headers vulkan-devel vulkan-mesa-layers opencl-mesa \
  vulkan-mesa-implicit-layers
```

> **Note:** the `vulkan-intel` / `libva-intel-driver` packages above are Intel-specific. Swap in the
> AMD (`vulkan-radeon`, `libva-mesa-driver`) or NVIDIA (`nvidia`, `nvidia-utils`) equivalents if
> you're on different hardware.

### Setup zram

Using `zram-generator`:

```bash
# Install the package
sudo pacman -S zram-generator

# Configure zram
sudo cp dotfiles/zram-generator.conf /etc/systemd/

# Enable the service
sudo systemctl enable --now systemd-zram-setup@zram0.service
```

---

## 🚀 Installation & Setup

> [!NOTE]
> For an automated installation, run the [setup.sh](./setup.sh) script

### 1. Enable Services

```bash
sudo systemctl enable sddm bluetooth cups fwupd

systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

### 2. Deploy Dotfiles

```bash
# Copy configurations
cp -r dotfiles/.config $HOME/
cp -r dotfiles/.local $HOME/

# Clone wallpapers
git clone https://github.com/dilanrojas/wallpapers.git $HOME/Pictures/wallpapers

# Set default shell
sudo usermod --shell /usr/bin/fish $USER
sudo usermod --shell /usr/bin/fish root

# Configure git
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# Update user directories
xdg-user-dirs-update

# Finalize theme & updatedb for locate
sudo updatedb
```

### Configure Boot/ESP Flags

These commands assume your ESP and boot partition is the first one on the disk.

```bash
sudo parted /dev/[your_disk] set 1 boot on
sudo parted /dev/[your_disk] set 1 esp on
```

Verify the changes:

```bash
sudo parted /dev/[your_disk] print
```

Expected output:

```text
╭─ jwd in ~
╰─❯ sudo parted /dev/nvme0n1 print
Model: SKHynix_HFS512GEM4X182N (nvme)
Disk /dev/nvme0n1: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  1001MB  1000MB  fat32              boot, esp  # <-- This is the important line
 2      1001MB  512GB   511GB   ext4
```

### Battery Tools (Useful for a Laptop)

```bash
# Install Power Profiles Daemon
sudo pacman -S power-profiles-daemon

# Enable the service
sudo systemctl enable --now power-profiles-daemon
```

### Configuring Persistent Workspaces in Waybar

Get your primary monitor name:

```bash
swaymsg -t get_outputs
```

Then update your Waybar config — locate the `workspaces` module and set the values accordingly:

```bash
nvim ~/.config/waybar/config.json
```

### 3. SDDM & Font Rendering (Optional)

```bash
# Install SDDM Astronaut (Japanese Aesthetic variant used here)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
```

### Improve Font Rendering

```bash
# Clone the repo and run the script
git clone https://github.com/maximilionus/lucidglyph && cd lucidglyph
sudo ./lucidglyph.sh install

# To remove:
# sudo ./lucidglyph.sh remove
```
