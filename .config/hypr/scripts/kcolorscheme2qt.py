#!/usr/bin/env python3
"""kcolorscheme2qt.py — convert a KDE color scheme (.colors) to the
qt5ct/qt6ct color-scheme format (QPalette serialization per state).

Port of KColorScheme::createApplicationPalette() (KDE kcolorscheme.cpp) plus
the KColorUtils/KHCY math (kguiaddons), so the derived Light/Mid/Midlight/Dark/
Shadow colors match what Plasma would compute. qt6ct's parser (see
qt6ct-common/qt6ct.cpp loadColorPlan) only understands this format — feeding it
a .colors file silently yields the default (light) palette.

Usage: kcolorscheme2qt.py <scheme.colors> <out.conf>
"""
import configparser
import math
import sys

# ------------------------------------------------------------------------------
# KHCY color space (kguiaddons/src/colors/kcolorspaces.cpp)
YC = (0.2126, 0.7152, 0.0722)  # Rec.709 luma weights


def clamp01(x):
    return 0.0 if x < 0.0 else (1.0 if x > 1.0 else x)


def gamma(n):
    return clamp01(n) ** 2.2


def igamma(n):
    return clamp01(n) ** (1.0 / 2.2)


def lumag(r, g, b):
    return r * YC[0] + g * YC[1] + b * YC[2]


def wrap(a):
    r = math.fmod(a, 1.0)
    return (1.0 + r) if r < 0.0 else (r if r > 0.0 else 0.0)


class KHCY:
    """KDE's hue/chroma/luma/alpha components."""

    def __init__(self, h=0.0, c=0.0, y=0.0, a=1.0):
        self.h, self.c, self.y, self.a = h, c, y, a

    @classmethod
    def from_rgb(cls, rf, gf, bf, af=1.0):
        """sRGB floats -> HCY (KHCY(const QColor&))"""
        r, g, b = gamma(rf), gamma(gf), gamma(bf)
        y = lumag(r, g, b)
        p, n = max(r, g, b), min(r, g, b)
        d = 6.0 * (p - n)
        if n == p:
            h = 0.0
        elif r == p:
            h = (g - b) / d
        elif g == p:
            h = (b - r) / d + 1.0 / 3.0
        else:
            h = (r - g) / d + 2.0 / 3.0
        c = 0.0 if (r == g == b) else max((y - n) / y, (p - y) / (1 - y))
        return cls(h, c, y, af)

    def to_rgb(self):
        """HCY -> sRGB floats (KHCY::qColor)"""
        _h, _c, _y = wrap(self.h), clamp01(self.c), clamp01(self.y)
        _hs = _h * 6.0
        if _hs < 1.0:
            th = _hs;            tm = YC[0] + YC[1] * th
        elif _hs < 2.0:
            th = 2.0 - _hs;      tm = YC[1] + YC[0] * th
        elif _hs < 3.0:
            th = _hs - 2.0;      tm = YC[1] + YC[2] * th
        elif _hs < 4.0:
            th = 4.0 - _hs;      tm = YC[2] + YC[1] * th
        elif _hs < 5.0:
            th = _hs - 4.0;      tm = YC[2] + YC[0] * th
        else:
            th = 6.0 - _hs;      tm = YC[0] + YC[2] * th
        if tm >= _y:
            tp = _y + _y * _c * (1.0 - tm) / tm
            to = _y + _y * _c * (th - tm) / tm
            tn = _y - (_y * _c)
        else:
            tp = _y + (1.0 - _y) * _c
            to = _y + (1.0 - _y) * _c * (th - tm) / (1.0 - tm)
            tn = _y - (1.0 - _y) * _c * tm / (1.0 - tm)
        if _hs < 1.0:
            r, g, b = tp, to, tn
        elif _hs < 2.0:
            r, g, b = to, tp, tn
        elif _hs < 3.0:
            r, g, b = tn, tp, to
        elif _hs < 4.0:
            r, g, b = tn, to, tp
        elif _hs < 5.0:
            r, g, b = to, tn, tp
        else:
            r, g, b = tp, tn, to
        return igamma(r), igamma(g), igamma(b)


class Color:
    def __init__(self, r, g, b, a=1.0):
        self.r, self.g, self.b, self.a = r, g, b, a  # sRGB floats

    @classmethod
    def parse(cls, text):
        t = text.strip()
        if t.startswith("#"):
            hp = t[1:]
            if len(hp) == 3:
                hp = "".join(x * 2 for x in hp)
            if len(hp) == 6:
                return cls(*((int(hp[i:i + 2], 16) / 255.0) for i in (0, 2, 4)))
            if len(hp) == 8:
                a = int(hp[0:2], 16) / 255.0
                return cls(*((int(hp[i:i + 2], 16) / 255.0) for i in (2, 4, 6)), a)
            raise ValueError(f"bad color: {t}")
        vals = [int(p) / 255.0 for p in t.split(",") if p.strip()]
        return cls(vals[0], vals[1], vals[2], vals[3] if len(vals) > 3 else 1.0)

    # -- KColorUtils ------------------------------------------------------------
    @property
    def hcy(self):
        return KHCY.from_rgb(self.r, self.g, self.b, self.a)

    def swap_hcy(self, **kw):
        k = self.hcy
        vals = dict(h=k.h, c=k.c, y=k.y, a=k.a)
        vals.update(kw)
        n = KHCY(**vals)
        rgb = n.to_rgb()
        return Color(rgb[0], rgb[1], rgb[2], n.a)

    def luma(self):
        return self.hcy.y

    def shade(self, ky, kc=0.0):        # KColorUtils::shade
        k = self.hcy
        return self.swap_hcy(y=clamp01(k.y + ky), c=clamp01(k.c + kc))

    def darken(self, ky, kc=1.0):       # KColorUtils::darken
        k = self.hcy
        return self.swap_hcy(y=clamp01(k.y * (1.0 - ky)), c=clamp01(k.c * kc))

    @staticmethod
    def mix(c1, c2, bias):              # KColorUtils::mix (KF6 premultiplied)
        if bias <= 0.0:
            return c1
        if bias >= 1.0:
            return c2
        a = c1.a + (c2.a - c1.a) * bias
        if a <= 0.0:
            return Color(0, 0, 0, 0)
        mixq = lambda x, y: x + (y - x) * bias
        r = clamp01(mixq(c1.r * c1.a, c2.r * c2.a)) / a
        g = clamp01(mixq(c1.g * c1.a, c2.g * c2.a)) / a
        b = clamp01(mixq(c1.b * c1.a, c2.b * c2.a)) / a
        return Color(r, g, b, a)

    @staticmethod
    def tint(base, color, amount):      # KColorUtils::tint
        if amount <= 0.0:
            return base
        if amount >= 1.0:
            return color
        bl = base.luma()
        cratio = lambda y1, y2: (max(y1, y2) + 0.05) / (min(y1, y2) + 0.05)

        def tint_luma(a):
            m = Color.mix(base, color, math.pow(a, 0.3))
            return bl + (m.luma() - bl) * a

        ri = cratio(bl, color.luma())
        rg = 1.0 + ((ri + 1.0) * amount * amount * amount)
        u, l, a = 1.0, 0.0, 0.5
        for _ in range(12):             # KF6: 12 binary search steps
            a = 0.5 * (l + u)
            if cratio(bl, tint_luma(a)) > rg:
                u = a
            else:
                l = a
        m = Color.mix(base, color, math.pow(a, 0.3))
        k = m.hcy
        k.y = bl + (k.y - bl) * amount
        return Color(*m.hcy.to_rgb(), m.a)

    def hex(self):
        fmt = lambda x: f"{int(round(clamp01(x) * 255)):02x}"
        return f"#{fmt(self.a)}{fmt(self.r)}{fmt(self.g)}{fmt(self.b)}"


# ------------------------------------------------------------------------------
# KColorScheme defaults (kcolorscheme.cpp) — one entry per SerializedColors field
def C(vals):
    r, g, b = vals
    return Color(r / 255, g / 255, b / 255)


DEFAULTS = {
    #           bgN              bgA              fN               fI
    "view":          (C((255, 255, 255)), C((247, 247, 247)), C((35, 38, 41)),  C((112, 125, 138))),
    "window":        (C((239, 240, 241)), C((227, 229, 231)), C((35, 38, 41)),  C((112, 125, 138))),
    "button":        (C((252, 252, 252)), C((163, 212, 250)), C((35, 38, 41)),  C((112, 125, 138))),
    "selection":     (C((61, 174, 233)),  C((163, 212, 250)), C((255, 255, 255)), C((112, 125, 138))),
    "tooltip":       (C((247, 247, 247)), C((239, 240, 241)), C((35, 38, 41)),  C((112, 125, 138))),
    "complementary": (C((42, 46, 50)),    C((27, 30, 32)),    C((252, 252, 252)), C((161, 169, 177))),
}
# fg extras: Link, Visited, Negative, Neutral, Positive (view/window share Breeze defaults)
FG_EXTRA = dict(fL=C((41, 128, 185)), fV=C((155, 89, 182)), fNeg=C((218, 68, 83)),
                fNeu=C((246, 116, 0)), fPos=C((39, 174, 96)))
SEL_FG_EXTRA = dict(fL=C((253, 188, 75)), fV=C((155, 89, 182)), fNeg=C((176, 55, 69)),
                    fNeu=C((198, 92, 0)), fPos=C((23, 104, 57)))
FOCUS, HOVER = C((61, 174, 233)), C((61, 174, 233))


class Cfg:
    """minimal KConfig-like reader"""

    def __init__(self, path):
        cp = configparser.ConfigParser(interpolation=None)
        cp.optionxform = str  # keep key case
        cp.read(path)
        self.cp = cp

    def has_group(self, name):
        return self.cp.has_section(name)

    def read(self, group, key, default=None):
        if self.cp.has_section(group) and self.cp.has_option(group, key):
            return self.cp.get(group, key)
        return default


def scheme_colors(cfg, state, setter):
    """(fg, bg) for a ColorSet + state, mirroring KColorSchemePrivate."""
    base = DEFAULTS[setter]

    tint = None
    if setter == "selection":
        if state == "Active":
            group, base_types = "Colors:Selection", "selection"
        else:
            # Inactive/Disabled take Window colors (GTK-like), possibly tinted
            group, base_types = "Colors:Window", "window"
            if state == "Inactive":
                change = cfg.read("ColorEffects:Inactive", "ChangeSelectionColor",
                                  cfg.read("ColorEffects:Inactive", "Enable", "true"))
                if str(change).strip().lower() in ("true", "1"):
                    tint = cfg.read("Colors:Selection", "BackgroundNormal",
                                    str(DEFAULTS["selection"][0].r * 255)) or None
                    tint = tint if isinstance(tint, str) else None
            tint = Color.parse(tint) if tint else None
    else:
        group, base_types = {"window": "Colors:Window", "button": "Colors:Button",
                             "view": "Colors:View", "tooltip": "Colors:Tooltip",
                             "complementary": "Colors:Complementary"}[setter], setter

    fg = dict
    fg = {}
    bg = {}
    fg["fN"] = Color.parse(cfg.read(group, "ForegroundNormal") or _s(base[2]))
    fg["fI"] = Color.parse(cfg.read(group, "ForegroundInactive") or _s(base[3]))
    for name, k2 in (("fL", "ForegroundLink"), ("fV", "ForegroundVisited"),
                     ("fNeg", "ForegroundNegative"), ("fNeu", "ForegroundNeutral"),
                     ("fPos", "ForegroundPositive")):
        extra = SEL_FG_EXTRA if base_types == "selection" else FG_EXTRA
        fg[name] = Color.parse(cfg.read(group, k2) or _s(extra[name]))
    bg["bgN"] = Color.parse(cfg.read(group, "BackgroundNormal") or _s(base[0]))
    bg["bgA"] = Color.parse(cfg.read(group, "BackgroundAlternate") or _s(base[1]))
    fg["focus"] = Color.parse(cfg.read(group, "DecorationFocus") or _s(FOCUS))
    fg["hover"] = Color.parse(cfg.read(group, "DecorationHover") or _s(HOVER))

    if tint is not None:
        bg["bgN"] = Color.tint(bg["bgN"], tint, 0.4)
        bg["bgA"] = Color.tint(bg["bgA"], tint, 0.4)

    # ---- StateEffects (kcolorscheme.cpp StateEffects ctor) -------------------
    if state == "Active":
        return fg, bg
    group_fx = {"Disabled": "ColorEffects:Disabled", "Inactive": "ColorEffects:Inactive"}[state]
    enabled_by_default = (state == "Disabled")
    enable = str(cfg.read(group_fx, "Enable", ("true" if enabled_by_default else "false"))).strip().lower() in ("true", "1")

    if enable:
        intensity = float(cfg.read(group_fx, "IntensityEffect",
                                   ("2" if state == "Disabled" else "0")))
        color_fx = float(cfg.read(group_fx, "ColorEffect",
                                  ("0" if state == "Disabled" else "1")))
        contrast_fx = float(cfg.read(group_fx, "ContrastEffect",
                                     ("1" if state == "Disabled" else "2")))
        a_int = float(cfg.read(group_fx, "IntensityAmount",
                               ("0.10" if state == "Disabled" else "0.0")))
        a_col = float(cfg.read(group_fx, "ColorAmount",
                               ("0.0" if state == "Disabled" else "-0.9")))
        a_con = float(cfg.read(group_fx, "ContrastAmount",
                               ("0.65" if state == "Disabled" else "0.25")))
        tint_color = (Color.parse(cfg.read(group_fx, "Color", "112,111,110"))
                      if color_fx > 0 else None)

        def brush_bg(co):  # StateEffects::brush(background)
            if intensity == 1:
                co = co.shade(a_int)
            elif intensity == 2:
                co = co.darken(a_int)
            elif intensity == 3:
                k = co.hcy
                co = co.swap_hcy(y=1.0 - clamp01((1.0 - k.y) * (1.0 - a_int)),
                                 c=1.0 - clamp01((1.0 - k.c) * 1.0))
            if color_fx == 1:
                co = co.darken(0.0, 1.0 - a_col)
            elif color_fx == 2:
                co = Color.mix(co, tint_color, a_col)
            elif color_fx == 3:
                co = Color.tint(co, tint_color, a_col)
            return co

        def brush_fg(co, bg):  # StateEffects::brush(foreground, background)
            if contrast_fx == 1:
                co = Color.mix(co, bg, a_con)
            elif contrast_fx == 2:
                co = Color.tint(co, bg, a_con)
            return brush_bg(co)

        for k in ("fN", "fI", "fL", "fV", "fNeg", "fNeu", "fPos", "focus", "hover"):
            fg[k] = brush_fg(fg[k], bg["bgN"])
        bg["bgN"] = brush_bg(bg["bgN"])
        bg["bgA"] = brush_bg(bg["bgA"])

    return fg, bg


def _s(color):
    return f"{int(round(color.r * 255))},{int(round(color.g * 255))},{int(round(color.b * 255))}"


# ---- KColorScheme::shade(role, contrast) ---------------------------------------
def ks_shade(color, role, contrast):
    contrast = clamp01(contrast) if contrast > 0 else max(-1.0, min(contrast, 1.0))
    if contrast == 0 and color.luma() == 0:  # normalize nan edge cases harmlessly
        contrast = 0.7
    y = color.luma()
    yi = 1.0 - y
    if y < 0.006:
        amt = {"LightShade": 0.05 + 0.95 * contrast,
               "MidShade": 0.01 + 0.20 * contrast,
               "DarkShade": 0.02 + 0.40 * contrast}.get(role, 0.03 + 0.60 * contrast)
        return color.shade(amt)
    if y > 0.93:
        amt = {"MidlightShade": -0.02 - 0.20 * contrast,
               "DarkShade": -0.06 - 0.60 * contrast,
               "ShadowShade": -0.10 - 0.90 * contrast}.get(role, -0.04 - 0.40 * contrast)
        return color.shade(amt)
    light_amount = (0.05 + y * 0.55) * (0.25 + contrast * 0.75)
    dark_amount = (-y) * (0.55 + contrast * 0.35)
    if role == "LightShade":
        return color.shade(light_amount)
    if role == "MidlightShade":
        return color.shade((0.15 + 0.35 * yi) * light_amount)
    if role == "MidShade":
        return color.shade((0.35 + 0.15 * y) * dark_amount)
    if role == "DarkShade":
        return color.shade(dark_amount)
    # ShadowShade:
    return color.shade(dark_amount).darken(0.5 + 0.3 * y)


# ---- createApplicationPalette --------------------------------------------------
ACTIVE, INACTIVE, DISABLED = "Active", "Inactive", "Disabled"

ROLE_ORDER = ["WindowText", "Button", "Light", "Midlight", "Dark", "Mid", "Text",
              "BrightText", "ButtonText", "Base", "Window", "Shadow", "Highlight",
              "HighlightedText", "Link", "LinkVisited", "AlternateBase", "NoRole",
              "ToolTipBase", "ToolTipText", "PlaceholderText"]


def create_palette(cfg):
    contrast = 0.1 * float(cfg.read("KDE", "contrast", "7"))
    palettes = {}
    for state in (ACTIVE, DISABLED, INACTIVE):
        w = scheme_colors(cfg, state, "window")
        v = scheme_colors(cfg, state, "view")
        b = scheme_colors(cfg, state, "button")
        s = scheme_colors(cfg, state, "selection")
        t = scheme_colors(cfg, ACTIVE, "tooltip")  # tooltips use Active in all states
        palettes[state] = {
            "WindowText": w[0]["fN"],          "Button": b[1]["bgN"],
            "Light": ks_shade(w[1]["bgN"], "LightShade", contrast),
            "Midlight": ks_shade(w[1]["bgN"], "MidlightShade", contrast),
            "Dark": ks_shade(w[1]["bgN"], "DarkShade", contrast),
            "Mid": ks_shade(w[1]["bgN"], "MidShade", contrast),
            "Text": v[0]["fN"],                "BrightText": Color(1, 1, 1),
            "ButtonText": b[0]["fN"],          "Base": v[1]["bgN"],
            "Window": w[1]["bgN"],
            "Shadow": ks_shade(w[1]["bgN"], "ShadowShade", contrast),
            "Highlight": s[1]["bgN"],          "HighlightedText": s[0]["fN"],
            "Link": v[0]["fL"],                "LinkVisited": v[0]["fV"],
            "AlternateBase": v[1]["bgA"],      "NoRole": Color(0, 0, 0),
            "ToolTipBase": t[1]["bgN"],        "ToolTipText": t[0]["fN"],
            "PlaceholderText": v[0]["fI"],
        }
    return palettes


def emit(conf_path, palettes):
    order = {"active_colors": ACTIVE, "disabled_colors": DISABLED, "inactive_colors": INACTIVE}
    with open(conf_path, "w") as f:
        f.write("[ColorScheme]\n")
        for key, state in order.items():
            vals = ", ".join(palettes[state][r].hex() for r in ROLE_ORDER)
            f.write(f"{key}={vals}\n")


def main():
    src, dst = sys.argv[1], sys.argv[2]
    palettes = create_palette(Cfg(src))
    emit(dst, palettes)
    p = palettes[ACTIVE]
    print(f"window={p['Window'].hex()} base={p['Base'].hex()} "
          f"text={p['WindowText'].hex()} highlight={p['Highlight'].hex()} "
          f"mid={p['Mid'].hex()} dark={p['Dark'].hex()}")


if __name__ == "__main__":
    main()
