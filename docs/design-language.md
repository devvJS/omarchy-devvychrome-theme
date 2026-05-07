# Devvychrome — Design Language

Devvychrome is a restrained, true-monochrome theme. Its goal is a calm,
cinematic surface for long engineering sessions — readable, atmospheric,
and free of stimulant color.

## Philosophy

Devvychrome treats color as a budget, and spends none of it.

Hierarchy is produced through:

- **Luminance** — the only carrier of meaning in the palette.
- **Spacing** — generous gutters, deliberate density.
- **Typography** — weight and tracking communicate role before color does.
- **Blur** — used sparingly to separate planes.
- **Elevation** — surfaces lift in luminance, never in hue.
- **Contrast** — soft rather than maximal; readability over drama.
- **Motion** — minimal, slow, and reversible.

What Devvychrome refuses:

- Saturated accent colors
- Neon, RGB, or "gamer" visual language
- Harsh OLED extremes (`#000000` against `#ffffff`)
- Decorative iconography that competes with content

## Influences

### Brutalist architecture

Devvychrome borrows from brutalism the same way the flagship wallpaper
does: a preference for concrete masses, matte surfaces, deliberate
weight, and forms that do not apologize for being functional. UI
surfaces should feel poured rather than rendered — flat planes,
honest edges, no decorative gloss.

### Cinematic environmental composition

The desktop is treated as a frame. Wallpaper, panels, and windows are
foreground, midground, and background elements in a single composition.
Atmosphere — fog, distance, soft falloff — does the same job here that
saturated accent color does in louder themes. The viewer's eye is led
by depth, not color.

### Negative-space philosophy

Empty space is content. The largest, calmest region of any
Devvychrome surface is intentional, and is reserved for the user's
work. Modules, panels, and ornament are pushed to the edges so the
center remains a place to think.

## Ultrawide composition strategy

Devvychrome is composed for ultrawide displays first; standard 16:9
should still work, but the design assumes the wallpaper, the bar, and
window layouts will be experienced at 21:9 or wider.

- **Anchor on the sides.** Visual weight (architectural mass,
  atmospheric falloff, Waybar) lives at the edges of the frame.
- **Hold the center open.** The middle third is reserved for the
  user's tiled terminals and editor panes. No wallpaper composition,
  module, or border should fight for that space.
- **Prefer horizontal rhythm.** Long horizontal bands of luminance
  read calmly across an ultrawide; vertical drama feels claustrophobic.
- **Plan for tiling.** Test against two- and three-pane Hyprland
  layouts. If a tile reveals a "hot" region of the wallpaper, the
  wallpaper, not the layout, is wrong.

## Environmental storytelling

Devvychrome surfaces should feel like they exist *somewhere*. The
flagship wallpaper sets a coastal, fog-bound, brutalist site; the
rest of the theme should feel coherent with that location:

- **Surfaces are damp concrete, not glass.** Matte, slightly textured
  in feel, never glossy or glassmorphic.
- **Light is overcast, not stage-lit.** Soft, diffuse contrast; no
  hard shadows, no spotlight effects.
- **Motion is weather, not animation.** Slow, low-amplitude, and
  ambient — never eager.
- **Distance is real.** Background panels recede in luminance the
  way fog recedes in the wallpaper.

The point is not to literalize the wallpaper in every component, but
to ensure no component contradicts it.

## Palette

`colors.toml` only carries the keys Omarchy supports. The semantic
palette below is the *full* design system: it informs Waybar styling,
custom modules, and any future scripts, but is not encoded in
`colors.toml` directly.

### Backgrounds

| Token    | Value     | Purpose                              |
| -------- | --------- | ------------------------------------ |
| absolute | `#111111` | Reserved for full-bleed deep voids.  |
| primary  | `#161616` | Default workspace / terminal canvas. |
| secondary| `#1d1d1d` | Sidebars, panels, secondary planes.  |

### Surfaces

| Token    | Value     | Purpose                              |
| -------- | --------- | ------------------------------------ |
| surface  | `#242424` | Cards, popovers, Waybar background.  |
| elevated | `#2b2b2b` | Hover and lifted surfaces.           |
| focused  | `#343434` | Active surface, focused input.       |

### Text

| Token     | Value     | Purpose                             |
| --------- | --------- | ----------------------------------- |
| primary   | `#e0e0e0` | Body and primary UI text.           |
| secondary | `#c8c8c8` | Supporting copy.                    |
| muted     | `#9a9a9a` | Tertiary metadata, placeholders.    |
| disabled  | `#6f6f6f` | Inactive states.                    |

### Borders

| Token    | Value     | Purpose                              |
| -------- | --------- | ------------------------------------ |
| inactive | `#242424` | Quiet dividers; nearly invisible.    |
| default  | `#343434` | Standard component borders.          |
| active   | `#5a5a5a` | Focus rings and active outlines.     |

### Status

Status tokens are deliberately collapsed in luminance. Meaning travels
through context (icon, position, label) rather than hue.

| Token   | Value     |
| ------- | --------- |
| success | `#8a8a8a` |
| warning | `#a0a0a0` |
| error   | `#7a7a7a` |
| info    | `#909090` |

### ANSI palette

Ships verbatim in `colors.toml` (`color0`–`color15`).

| Slot     | Value     |
| -------- | --------- |
| black    | `#1b1b1b` |
| red      | `#7a7a7a` |
| green    | `#8a8a8a` |
| yellow   | `#a0a0a0` |
| blue     | `#909090` |
| magenta  | `#858585` |
| cyan     | `#9a9a9a` |
| white    | `#dcdcdc` |

Brights step luminance up by roughly one band (see `colors.toml` for
the exact values).

### Cursor and selection

| Token                 | Value     |
| --------------------- | --------- |
| cursor                | `#d0d0d0` |
| selection.background  | `#3a3a3a` |
| selection.foreground  | `#e0e0e0` |

## Application guidance

- **Terminal.** Lean on the ANSI palette as-is; do not override per-app.
- **Editors.** Map syntax categories to luminance bands rather than hue:
  comments at `muted`, identifiers at `secondary`, keywords at `primary`,
  strings at a `c8`–`d0` band.
- **Waybar.** Surface = `#242424`, text = `primary`, separators = `inactive`.
  Avoid color-coded modules; use icon weight and spacing instead.
- **Hyprland.** Inactive borders at `inactive`, active borders at `active`
  with a single-pixel weight. Gaps and blur do the rest.
- **Hyprlock.** Background at `absolute`; foreground at `primary`.

## Wallpaper standards

The wallpaper set is part of the theme, not decoration around it.
Every Devvychrome wallpaper must read as a member of the same world
as the flagship.

### Reference

- **Flagship:** `backgrounds/devvychrome-coastal-monolith-3440x1440.png`
- **Subject:** brutalist concrete architecture under coastal fog
- **Composition:** ultrawide-first, with the central third held open
- **Mood:** quiet, isolated, engineering-grade

New wallpapers are evaluated against this reference. They do not
need to be coastal or architectural, but they must share its
restraint, depth, and matte luminance.

### Composition rules

- **Preserve the center.** The middle third of the frame must read
  as breathing room — low contrast, low detail, suitable as a
  backdrop for tiled terminals and editor panes.
- **Avoid bright focal points.** No specular highlights, no light
  sources brighter than the `text.primary` luminance band. Visual
  weight is carried by mass and atmosphere, not points of light.
- **Maintain low visual clutter.** Few subjects, large forms,
  generous negative space. If a wallpaper has more than two visual
  ideas, it is too busy.
- **Prioritize atmospheric depth.** Foreground, midground, and
  background should be readable as separate planes via luminance and
  haze alone. Depth is the substitute for color.
- **Support terminal-centric workflows.** When a window is opened
  over the wallpaper, the wallpaper should recede. Test with a
  realistic Hyprland tile layout before committing.

### Technical constraints

- **Aspect ratio.** Native renders at 21:9 (e.g. `3440x1440`,
  `5120x2160`). 16:9 crops are acceptable as derivatives but should
  not be the master.
- **Color.** True grayscale; saturation must be zero. Convert from
  source via a luminance-preserving desaturation, not a hue rotation.
- **Luminance range.** Stay within roughly `#0e0e0e` and `#cfcfcf`.
  Avoid pure black and pure white; both undermine the soft-contrast
  philosophy.
- **Texture.** Matte. Concrete, fog, brushed metal, weathered stone
  are all in scope. Glass, chrome reflections, lens flares, and bokeh
  highlights are out.
- **File format.** PNG for masters with sharp architectural edges;
  high-quality JPEG (q ≥ 92) is acceptable for atmospheric pieces
  where banding would otherwise be visible.
- **Naming.** `devvychrome-<descriptor>-<width>x<height>.<ext>`,
  lowercase, hyphenated. Example:
  `devvychrome-coastal-monolith-3440x1440.png`.

### Disqualifying traits

- Cyberpunk, neon, or RGB aesthetics.
- Bright sky, sunset, or any saturated atmospheric tinting.
- Heavy focal clutter, dense subjects, or any "wallpaper as art piece"
  composition that competes with foreground windows.
- Photographic effects (chromatic aberration, film grain overlays,
  light leaks) used as primary visual interest.
- Logos, type, or any literal branding.

## Anti-patterns

- Colored module text in Waybar.
- Bright workspace indicators or accent strokes.
- Drop shadows used for depth — prefer luminance steps.
- Per-app theme overrides that diverge from `colors.toml`.
- Wallpapers that require windows to be moved aside to be appreciated.
