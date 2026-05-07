# Devvychrome

A restrained, true-monochrome theme for [Omarchy](https://omarchy.org).

Devvychrome is built for focused engineering workflows, atmospheric computing,
and low-distraction environments. It carries hierarchy through luminance,
spacing, and typography — not saturated accent colors.

## Overview

Devvychrome is one Omarchy theme distributed from a single repository.
The source of truth is `colors.toml`; Omarchy consumes that file and
generates configuration for the supported applications (Ghostty,
Alacritty, Kitty, btop, Chromium, Hyprland, Hyprlock, Mako, SwayOSD,
Walker, and Waybar).

## Design philosophy

Devvychrome is not a color-driven theme. The palette is intentionally
desaturated; charcoal, graphite, ash, smoke, fog, and steel form the
entire vocabulary. Visual hierarchy is produced by:

- luminance
- spacing
- typography
- blur
- elevation
- contrast
- motion

There are no neon accents, no RGB cycling, no gamer aesthetic. Surfaces
are matte. Contrast is soft rather than harsh OLED black-on-white, which
reduces visual fatigue on ultrawide and secondary displays.

For the full palette and design rules, see
[`docs/design-language.md`](docs/design-language.md).

## Installation

Devvychrome is installed the same way as any Omarchy theme — from its
public Git URL. Once published, it can be added with:

```bash
omarchy-theme-install https://github.com/<your-handle>/omarchy-devvychrome-theme
```

After installation, select **Devvychrome** from the Omarchy theme menu.

User-installed themes live in `~/.config/omarchy/themes`; the bundled
themes Omarchy ships with live in `~/.local/share/omarchy/themes` and
should not be modified.

## Local development

Clone the repository into the user theme directory to iterate against
a live Omarchy install:

```bash
git clone https://github.com/<your-handle>/omarchy-devvychrome-theme \
  ~/.config/omarchy/themes/devvychrome
```

Edit `colors.toml`, then re-apply the theme through the Omarchy menu so
generated configs are rebuilt.

For Waybar work, prototype on a feature branch and never overwrite the
user's live `~/.config/waybar` — see
[`docs/waybar-roadmap.md`](docs/waybar-roadmap.md).

## Repository layout

```
.
├── colors.toml            # Omarchy source-of-truth palette
├── backgrounds/           # Wallpapers shipped with the theme
├── screenshots/           # Preview imagery for the README
├── docs/
│   ├── design-language.md # Visual philosophy and full palette
│   └── waybar-roadmap.md  # Planned Waybar refinements
├── LICENSE
└── README.md
```

## Roadmap

- Curated grayscale wallpaper set under `backgrounds/`
- Preview screenshots for terminal, Hyprland desktop, and Waybar
- Devvychrome-native Waybar styling (see the Waybar roadmap)
- Optional minimal music visualizer and now-playing module with
  hover-revealed playback controls
- Light variant exploration, deferred until the dark variant lands

## License

Devvychrome is released under the MIT License. See [`LICENSE`](LICENSE).
