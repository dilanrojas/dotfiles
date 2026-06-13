# Sway Dotfiles

A sleek, productive Sway environment with a focus on the GNOME/Adwaita ecosystem.

## Preview

<img src="./preview/image.png" alt="Dotfiles preview" />

## Keybindings

The `SUPER` key (Windows key) is your primary modifier.

### Applications & Utilities

| Keybind | Action |
| --- | --- |
| `SUPER` + `Enter` | Open Terminal (Alacritty) |
| `SUPER` + `B` | Open Web Browser (Brave) |
| `SUPER` + `E` | Open File Manager (Nautilus) |
| `SUPER` + `M` | App Launcher (Rofi) |
| `SUPER` + `V` | Clipboard History |
| `Print` | Screenshot (Area Select) |
| `SUPER` + `Shift` + `Q` | Logout Menu (Wlogout) |

### Window Management

| Keybind | Action |
| --- | --- |
| `SUPER` + `Q` | Kill Active Window |
| `SUPER` + `F` | Toggle Fullscreen |
| `SUPER` + `Shift` + `F` | Toggle Floating |
| `SUPER` + `H/J/K/L` | Move Focus (Left/Down/Up/Right) |
| `SUPER` + `Shift` + `H/J/K/L` | Move Window Position |
| `SUPER` + `Ctrl` + `H/J/K/L` | Resize Active Window |

### Workspaces

| Keybind | Action |
| --- | --- |
| `SUPER` + `1-0` | Switch to Workspace 1-10 |
| `SUPER` + `Shift` + `1-0` | Move Window to Workspace 1-10 |
| `SUPER` + `U` | Toggle Special Workspace (Scratchpad) |


## Themes

I usually switched between [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) and [Gruvbox](https://github.com/morhetz/gruvbox).
Feel free to edit `~/.config/alacritty/alacritty.toml` and add more themes into `~/.config/alacritty/themes`.
Also, change your NeoVim theme on `~/.config/nvim/lua/plugins/colorscheme.lua`. The list of themes is available at `~/.config/nvim/lua/plugins/themes.lua`.

---

## 🛠️ Core Components

* **Window Manager:** [Sway](https://swaywm.org/)
* **Bar:** [Waybar](https://github.com/Alexays/Waybar)
* **Shell:** [Fish](https://fishshell.com/) with [Starship](https://starship.rs/)
* **Terminal:** [Alacritty](https://alacritty.org/)
* **App Launcher:** [Rofi](https://github.com/davatorium/rofi)
* **File Manager:** [Nautilus](https://apps.gnome.org/en/Nautilus/)
* **Editor:** [Neovim](https://neovim.io/) + [LazyVim](http://www.lazyvim.org/)
* **SDDM Theme:** [SDDM Astronaut](https://github.com/Keyitdev/sddm-astronaut-theme)
* **Wallpapers:** [My Collection](https://github.com/dilanrojas/wallpapers.git)

---

## 📦 List of Packages

### ❄️ Sway & Desktop

The core environment including fonts, UI tools, and GNOME apps.

```bash
sudo pacman -S sway swaybg swayidle swayosd mako wmname sddm hyprpicker qt6ct qt5ct waybar nwg-look nwg-displays adw-gtk-theme polkit-gnome xdg-desktop-portal-wlr xdg-desktop-portal-gtk alacritty fish starship lsd bat nautilus gnome-disk-utility loupe showtime gnome-text-editor gnome-calendar gnome-clocks gnome-calculator papers grim slurp cliphist neovim nano brightnessctl pamixer ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-iosevkaterm-nerd woff2-font-awesome noto-fonts-emoji dconf-editor kcolorchooser libsecret ruby nodejs npm ripgrep fd fzf luarocks gcc lazygit git udiskie udisks2 libappindicator unzip unrar wget curl mlocate fastfetch python-pipx gnome-keyring seahorse libsecret ksshaskpass ttf-opensans breeze libnotify rofi wireless-regdb
```

AUR Helper

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -rsi
cd .. && rm -rf yay
```

Sway FX

```bash
yay -S swayfx
```

Fonts & Basic Apps

```bash
yay -S ttf-plemoljp-bin waybar-module-pacman-updates-git wlogout brave-bin onlyoffice-bin epson-inkjet-printer-escpr ttf-ms-fonts downgrade rate-mirrors-bin --noconfirm
```

```bash
# A simple program for viewing markdown files on the command line
pipx install rich-cli
```

### 🎧 Audio & Connectivity

Sound servers, Bluetooth, and Printing services.

```bash
sudo pacman -S pipewire pipewire-pulse pipewire-alsa alsa-utils pavucontrol pipewire-jack wireplumber bluez bluez-utils bluetui cups cups-pdf
```

Media codecs

```bash
sudo pacman -S gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly x265 x264
```

### 🖥️ Xorg & Graphics & Gaming

Drivers and base display server components for hardware acceleration.

```bash
sudo pacman -S xorg xorg-server libva libva-intel-driver intel-media-driver mesa vulkan-intel vulkan-icd-loader vulkan-headers vulkan-devel vulkan-mesa-layers opencl-mesa vulkan-mesa-implicit-layers
```

### Setup zram

Using zram-generator

```bash
# Install the package
sudo pacman -S zram-generator

# Configure zram
sudo cp dotfiles/zram-generator.conf /etc/systemd/

# Enable the service
sudo systemctl enable --now  systemd-zram-setup@zram0.service
```

### Configure mirrors

```bash
rate-mirrors --allow-root --protocol https arch | grep -v '#' | sudo tee /etc/pacman.d/mirrorlist
```

---

## 🚀 Installation & Setup

### 1. Enable Services

```bash
sudo systemctl enable sddm bluetooth cups

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

# Finalize theme & updatedb for locate
sudo updatedb
```

### Battery tools (Useful for a Laptop)

```bash
# Install Power Profiles Daemon
sudo pacman -S power-profiles-daemon

# Enable the services
sudo systemctl enable --now power-profiles-daemon
```

### Configuring persistent workspaces in Waybar

Get your primary monitor name.

```bash
swaymsg -t get_outputs
```

Update your waybar config.
Locate the workspaces module and check the values.

```bash
nvim ~/.config/waybar/config.json
```

### 3. SDDM & Font Rendering (Optional)

```bash
# Install SDDM Astronaut (I use Japanese Aesthetic)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
```

### Improve Font Rendering (Optional, might be too aggressive)

```bash
# Clone the repo and run the script
git clone https://github.com/maximilionus/lucidglyph && cd lucidglyph
sudo ./lucidglyph.sh install

# Use this for removing
#sudo ./lucidglyph.sh remove
```
