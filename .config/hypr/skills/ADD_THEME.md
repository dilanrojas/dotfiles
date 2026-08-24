# Add a Neovim-Based Theme (Agent Skill)

Use this guide when asked to "add a theme" to this Hyprland + Neovim (LazyVim) setup.
It is fully self-contained so any agent/model can follow it without prior context.

## What "adding a theme" means

A switchable theme touches **four** places. All four must exist or the theme
breaks at apply time (the switcher `hypr_theme.sh` reads all of them):

| # | File | Purpose |
|---|------|---------|
| 1 | `~/.config/hypr/themes.json` | Theme registry entry (label, wallpaper, nvim scheme, alacritty theme, palette, icons) |
| 2 | `~/.config/alacritty/themes/<key>.toml` | Alacritty 16-color terminal palette |
| 3 | `~/.config/hypr/wallpapers/<key>/arch.jpg` | Wallpaper (recolored "ARCH" SVG) |
| 4 | `~/.config/nvim/lua/plugins/themes.lua` | LazyVim plugin spec + **transparency** enable |

The switcher is `~/.config/hypr/scripts/hypr_theme.sh`. It reads `themes.json`
and rewrites waybar/rofi/dunst/alacritty/hyprland/nvim + sets the wallpaper.
It only consumes from the alacritty toml: `[colors.primary]` `background`/`foreground`
and `[colors.normal]` `black red green yellow blue magenta cyan white`.

---

## Step-by-step

Pick a trending neovim colorscheme from <https://dotfyle.com/neovim/colorscheme/trending>
(or any repo). Choose a stable `key` (e.g. `vesper`, `nightfox`).

### 1. Get the palette (the hard part)

Fetch the theme's **terminal color mapping** from its source (not the marketing README):

- `lua/<name>/colors.lua`, `lua/<name>/init.lua`, `autoload/<name>.vim`, or `colors/<name>.vim`
- Look for `terminal_color_0..15`, `g:terminal_ansi_colors`, or `g:terminal_color_*`.

Map them onto Alacritty's layout:

```
normal.black  = terminal_color_0
normal.red    = terminal_color_1
normal.green  = terminal_color_2
normal.yellow = terminal_color_3
normal.blue   = terminal_color_4
normal.magenta= terminal_color_5
normal.cyan   = terminal_color_6
normal.white  = terminal_color_7
bright.*      = terminal_color_8..15   (bright.black = _8, ... bright.white = _15)
primary.background = the theme's Normal bg (often terminal_color_background or bg0)
primary.foreground = the theme's Normal fg
```

If the theme ships an official `extras/alacritty/*.toml`, just **use it as-is**
(format is identical). Nightfox/Cyberdream/Tokyonight/Catppuccin do.

`blend_hex(a, b, t)` in lua = `a*(1-t) + b*t` per channel.

### 2. Write the alacritty toml

`~/.config/alacritty/themes/<key>.toml`:

```toml
# <key> alacritty theme (generated from the neovim colorscheme)

[colors.primary]
background = '#101010'
foreground = '#cccccc'

[colors.cursor]
text = '#cccccc'
cursor = '#cccccc'

[colors.selection]
text = '#cccccc'
background = '#101010'

[colors.normal]
black = '#101010'
red = '#FF8080'
green = '#82D9C2'
yellow = '#FFC799'
blue = '#82D9C2'
magenta = '#FFCFA8'
cyan = '#A0A0A0'
white = '#CCCCCC'

[colors.bright]
black = '#65737E'
red = '#FF8080'
green = '#FFCFA8'
yellow = '#FFCFA8'
blue = '#65737E'
magenta = '#FF8080'
cyan = '#FFCFA8'
white = '#7E7E7E'
```

> **GOTCHA — positional args in bash:** when generating this from a shell
> function, the 10th+ argument MUST use braces: use `${12}` NOT `$12`.
> `$12` is parsed as `$1` + `2` and leaks the theme name into the value
> (e.g. `black = 'sonokai2'`). This is the #1 bug to avoid.

### 3. Generate the wallpaper

The template is `~/.config/hypr/wallpapers/wallpaper_template.svg`
(plain "ARCH" text on a solid background). Recolor and export to JPEG:

```bash
gen_wall() {
  local key="$1" bg="$2" fg="$3"
  hex2rgb() { local h="${1#\#}"; echo "$((16#${h:0:2})), $((16#${h:2:2})), $((16#${h:4:2}))"; }
  local rgb_bg rgb_fg
  rgb_bg=$(hex2rgb "$bg"); rgb_fg=$(hex2rgb "$fg")
  local out="$HOME/.config/hypr/wallpapers/$key"; mkdir -p "$out"
  local svg; svg=$(cat "$HOME/.config/hypr/wallpapers/wallpaper_template.svg")
  svg="${svg//rgb(255, 255, 255)/rgb($rgb_bg)}"   # background
  svg="${svg//rgb(85, 85, 85)/rgb($rgb_fg)}"       # ARCH text
  printf '%s' "$svg" > "$out/_wp.svg"
  rsvg-convert -w 1920 -h 1200 "$out/_wp.svg" -o "$out/_wp.png"
  magick "$out/_wp.png" -quality 92 "jpg:$out/arch.jpg"   # MUST be real JPEG, not .png named .jpg
  rm -f "$out/_wp.svg" "$out/_wp.png"
}
gen_wall <key> "<bg>" "<fg>"
```

> `rsvg-convert` outputs PNG even with a `.jpg` name — always re-encode with
> `magick`/`convert` to a real JPEG, or hyprpaper may choke.

> Name it **`arch.jpg`** inside the folder (matches existing light-theme
> convention and keeps `themes.json` simple).

### 4. Add the `themes.json` entry

Append before the final `}` (add a trailing comma to the previous entry):

```json
  "<key>": {
    "label": "<Pretty Name>",
    "wallpaper": "arch.jpg",
    "neovim_scheme": "<colorscheme-name>",
    "alacritty_theme": "<key>.toml",
    "palette": {
      "active": "<accent-hex>",
      "inactive": "<dimmed-accent-hex>"
    },
    "icons": "Yaru-<hue>-dark"
  }
```

- `neovim_scheme`: the exact string passed to `:colorscheme` (usually the repo name).
- `active`/`inactive`: the theme's signature accent (used for Hyprland borders +
  waybar). `inactive` should be a darkened version.
- `icons`: pick a matching `Yaru-*` icon theme (`-dark` for dark themes).

Validate: `jq empty ~/.config/hypr/themes.json`.

### 5. Register the Neovim plugin (transparent!)

Append a spec to `~/.config/nvim/lua/plugins/themes.lua` (before the final `}`).
Every theme MUST be made transparent. Use the theme's native option when it has one:

```lua
  {
    "owner/<repo>.nvim",
    name = "<key>",
    lazy = false,
    priority = 1000,
    config = function()
      require("<key>").setup({ transparent = true })
    end,
  },
```

Known transparency knobs (verify against the repo if unsure):

| Theme | Transparent option |
|-------|--------------------|
| vesper | `require("vesper").setup({ transparent = true })` |
| nightfox | `require("nightfox").setup({ options = { transparent = true, terminal_colors = false } })` |
| cyberdream | `require("cyberdream").setup({ transparent = true })` |
| sonokai | `vim.g.sonokai_transparent_background = 1; vim.g.sonokai_disable_background = 1` |
| onedark | `require("onedark").setup({ style = "darker", transparent = true })` |
| catppuccin / tokyonight / kanagawa / etc. | see existing entries in the file |

> **oxocarbon special case:** it has NO native transparency and is Fennel-based.
> Two fixes required:
> 1. Add `build = false` to the spec (otherwise lazy tries to `luarocks`/`fennel`
>    build and fails with `lua5.1: No such file`). The repo ships precompiled Lua,
>    so no build is needed.
> 2. Force transparency via a `ColorScheme` autocmd:
> ```lua
>   {
>     "nyoom-engineering/oxocarbon.nvim",
>     name = "oxocarbon",
>     lazy = false,
>     priority = 1000,
>     build = false,
>     config = function()
>       vim.api.nvim_create_autocmd("ColorScheme", {
>         pattern = "oxocarbon",
>         callback = function()
>           local hl = vim.api.nvim_set_hl
>           for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr",
>             "CursorLineNr", "VertSplit", "NormalFloat", "FloatBorder",
>             "TelescopeNormal", "TelescopeBorder", "NvimTreeNormal",
>             "StatusLineNC", "WinBar", "WinBarNC" }) do
>             hl(0, g, { bg = "NONE" })
>           end
>         end,
>       })
>     end,
>   },
> ```

Validate lua: `luajit -e 'assert(loadfile(...))'` or just open nvim and read `:Lazy` errors.

---

## Final checklist

- [ ] `themes.json` parses (`jq empty`)
- [ ] `~/.config/alacritty/themes/<key>.toml` exists, no `<key>N` leaked values
- [ ] `~/.config/hypr/wallpapers/<key>/arch.jpg` is a real JPEG
- [ ] `themes.lua` has the spec, transparent, and (for oxocarbon) `build = false`
- [ ] Twice-confirm alacritty bright colors use `${12}`..`${19}` braces if scripted

Switch with `hypr_theme.sh <key>` or the rofi theme menu. The nvim plugin
installs on next `nvim` launch (`:Lazy sync`).
