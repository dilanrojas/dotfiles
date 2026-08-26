# Add a Theme (Agent Skill)

Use this guide when asked to "add a theme" to this Hyprland + Neovim (LazyVim) setup.
Each theme is a **self-contained folder** under `~/.config/hypr/themes/<key>/`. The
switcher (`hypr_theme.sh`) reads that folder and writes generated copies into each
app's own config dir — it never reads a central registry.

## What "adding a theme" means

A switchable theme touches **one folder** plus the shared wallpaper template. A theme
folder contains everything that was previously scattered across the system:

```
~/.config/hypr/themes/<key>/
  config.json      # metadata: label, wallpaper, neovim_scheme, system_theme, opacity, icons, palette
  alacritty.toml   # SOLID [colors.*] terminal palette (no alpha)
  rofi.rasi        # SOLID: accent, bg-primary, bg-secondary, fg
  waybar.css       # SOLID @define-color set (fg/bg/accent/black/blue/cyan/green/magenta/red/yellow)
  swayosd.css      # SOLID: bg, border, segment, progress
  dunstrc          # ONLY the 3 sed lines: background, foreground, frame_color (SOLID)
  nvim.lua         # ONLY the active theme's LazyVim colorscheme activation
                   # (the plugin install spec lives in nvim/lua/plugins/themes.lua)
  wallpapers/      # wallpaper image(s)
```

The switcher generates the *live* copies from these sources, injecting transparency
from `config.json.opacity` + the master switch (`EFFECTS` in
`~/.config/hypr/themes/current_theme`):

- `~/.config/alacritty/active_theme.toml`  ← copy of `alacritty.toml` (alacritty.toml imports it)
- `~/.config/rofi/active_theme.rasi`       ← `rofi.rasi` + injected `bg-primary-opacity` (config.rasi imports it)
- `~/.config/waybar/theme.css`             ← `waybar.css` with `bg` wrapped in `alpha(...)` (style.css imports it)
- `~/.config/swayosd/theme.css`            ← `swayosd.css` with `bg` wrapped in `alpha(...)` (style.css imports it)
- `~/.config/dunst/dunstrc`                ← `dunstrc` lines sed in (background gets the alpha)
- `~/.config/nvim/lua/plugins/colorscheme.lua` ← copy of `nvim.lua`
- `~/.config/hypr/config/looks.lua`        ← borders sed from `palette`
- hyprpaper wallpaper + gsettings icon theme + `system_theme.sh`

**Rule of thumb:** if an app can import/include a file, the theme folder holds that
file and the app's config imports the generated copy. If it can't (dunst, hyprland
looks.lua), the value is `sed`-patched from the theme's source file.

## Step-by-step

Pick a trending neovim colorscheme from <https://dotfyle.com/neovim/colorscheme/trending>
(or any repo). Choose a stable `key` (e.g. `vesper`, `nightfox`).

### 1. Get the palette

Fetch the theme's **terminal color mapping** from its source
(`lua/<name>/colors.lua`, `autoload/<name>.vim`, `colors/<name>.vim`); look for
`terminal_color_0..15` / `g:terminal_ansi_colors`. Map onto Alacritty's layout:

```
normal.black  = terminal_color_0      bright.black  = terminal_color_8
normal.red    = terminal_color_1      bright.red    = terminal_color_9
normal.green  = terminal_color_2      ...
normal.yellow = terminal_color_3
normal.blue   = terminal_color_4
normal.magenta= terminal_color_5
normal.cyan   = terminal_color_6
normal.white  = terminal_color_7
primary.background = the theme's Normal bg
primary.foreground = the theme's Normal fg
```

If the theme ships `extras/alacritty/*.toml`, use it as-is.

### 2. Scaffold the theme folder

```bash
KEY=mytheme
TH="$HOME/.config/hypr/themes/$KEY"
mkdir -p "$TH/wallpapers"
```

### 3. Write the files

**`$TH/alacritty.toml`** (solid — no alpha):

```toml
[colors.primary]
background = '#101010'
foreground = '#cccccc'

[colors.normal]
black = '#101010'
red   = '#FF8080'
green = '#82D9C2'
yellow= '#FFC799'
blue  = '#82D9C2'
magenta= '#FFCFA8'
cyan  = '#A0A0A0'
white = '#CCCCCC'

[colors.bright]
black = '#65737E'
red   = '#FF8080'
green = '#FFCFA8'
yellow= '#FFCFA8'
blue  = '#65737E'
magenta= '#FF8080'
cyan  = '#FFCFA8'
white = '#7E7E7E'
```

**`$TH/rofi.rasi`** (solid — `bg-primary-opacity` is generated at runtime, don't add it):

```
* {
    accent: #82D9C2;
    bg-primary: #101010;
    bg-secondary: #101010;
    fg: #cccccc;
}
```

**`$TH/waybar.css`** (solid):

```
@define-color fg #cccccc;
@define-color bg #101010;
@define-color accent #82D9C2;

@define-color black #101010;
@define-color blue #82D9C2;
@define-color cyan #A0A0A0;
@define-color green #82D9C2;
@define-color magenta #FFCFA8;
@define-color red #FF8080;
@define-color yellow #FFC799;
```

**`$TH/swayosd.css`** (solid):

```
@define-color bg #101010;
@define-color border #82D9C2;
@define-color segment #484848;
@define-color progress #cccccc;
```

> `segment` = a slightly lighter shade of the bg. Use `#484848` for dark themes,
> `#dddddd` for light themes.

**`$TH/dunstrc`** (only these 3 lines):

```
background = "#101010"
foreground = "#cccccc"
frame_color = "#cccccc"
```

**`$TH/config.json`**:

```json
{
  "label": "My Theme",
  "wallpaper": "arch.jpg",
  "neovim_scheme": "mytheme",
  "system_theme": "dark",
  "opacity": 0.9,
  "icons": "Yaru-mytheme-dark",
  "palette": {
    "active": "#82D9C2",
    "inactive": "#456a63"
  }
}
```

- `neovim_scheme`: exact string passed to `:colorscheme`.
- `palette.active` / `inactive`: the accent (hyprland borders + rofi) and a darkened
  version (inactive borders).
- `icons`: a matching `Yaru-*` icon theme (`-dark` for dark themes).
- `opacity`: optional, defaults to `0.9`.

**`$TH/nvim.lua`** — ONLY the active theme's colorscheme activation. This file is
copied verbatim to `~/.config/nvim/lua/plugins/colorscheme.lua` by the switcher, so it
must NOT contain the plugin install spec (that belongs in `themes.lua`, below). It
just tells LazyVim which already-installed colorscheme to load:

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mytheme",
    },
  },
}
```

> If the theme needs an explicit `require("mytheme").load()` or a non-default
> `style`, handle that in the `themes.lua` plugin spec (the switcher never touches
> `themes.lua`). `colorscheme.lua` carries only the active theme.

### 3b. Register the plugin in `themes.lua`

The plugin install spec goes in the **master registry**
`~/.config/nvim/lua/plugins/themes.lua` — not in the theme folder. Every installable
neovim colorscheme lives there as one entry, each configured to be **fully
transparent** (e.g. `transparent = true`). Find the spec from the repo's docs and
append it before the final `}`:

```lua
  {
    "owner/mytheme.nvim",
    name = "mytheme",
    lazy = false,
    priority = 1000,
    config = function()
      require("mytheme").setup({ transparent = true })
      require("mytheme").load()
    end,
  },
```

This is the only manual step outside the theme folder: adding a new theme means
editing `themes.lua` (add spec) **and** creating the `$TH/` folder (with the
colorscheme-only `nvim.lua`). The switcher copies `$TH/nvim.lua` → `colorscheme.lua`
to pick the active one; LazyVim loads the matching spec from `themes.lua`.

### 4. Generate the wallpaper

The template is `~/.config/hypr/themes/wallpaper_template.svg` (plain "ARCH" text on a
solid background). Recolor and export to JPEG:

```bash
gen_wall() {
  local key="$1" bg="$2" fg="$3"
  hex2rgb() { local h="${1#\#}"; echo "$((16#${h:0:2})), $((16#${h:2:2})), $((16#${h:4:2}))"; }
  local rgb_bg rgb_fg
  rgb_bg=$(hex2rgb "$bg"); rgb_fg=$(hex2rgb "$fg")
  local out="$HOME/.config/hypr/themes/$key/wallpapers"; mkdir -p "$out"
  local svg; svg=$(cat "$HOME/.config/hypr/themes/wallpaper_template.svg")
  svg="${svg//rgb(255, 255, 255)/rgb($rgb_bg)}"
  svg="${svg//rgb(85, 85, 85)/rgb($rgb_fg)}"
  printf '%s' "$svg" > "$out/_wp.svg"
  rsvg-convert -w 1920 -h 1200 "$out/_wp.svg" -o "$out/_wp.png"
  magick "$out/_wp.png" -quality 92 "jpg:$out/arch.jpg"
  rm -f "$out/_wp.svg" "$out/_wp.png"
}
gen_wall mytheme "<bg>" "<fg>"
```

### 5. Switch

```bash
hypr_theme.sh mytheme        # or run it with no arg for the rofi menu
```

The first time you switch to a theme whose nvim plugin isn't installed yet, the
switcher runs `:Lazy install` in any running nvim; the plugin installs on next
launch. The stored `config.json` drives the rest.

## Final checklist

- [ ] `~/.config/hypr/themes/<key>/` has `config.json`, `alacritty.toml`, `rofi.rasi`,
      `waybar.css`, `swayosd.css`, `dunstrc`, `nvim.lua`, `wallpapers/`
- [ ] `jq empty ~/.config/hypr/themes/<key>/config.json` passes
- [ ] `hypr_theme.sh <key>` applies wallpaper, alacritty, rofi, waybar, dunst, swayosd,
      hyprland borders, icons, and nvim
- [ ] `toggle_effects.sh off/on` toggles transparency everywhere
