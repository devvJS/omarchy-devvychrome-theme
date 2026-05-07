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

## Anti-patterns

- Colored module text in Waybar.
- Bright workspace indicators or accent strokes.
- Drop shadows used for depth — prefer luminance steps.
- Per-app theme overrides that diverge from `colors.toml`.
