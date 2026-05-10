# Devvychrome — wlogout

A monochrome, instrument-strip power console for
[wlogout](https://github.com/ArtsyMacaw/wlogout). Five evenly sized
operational tiles — lock, logout, suspend, reboot, shutdown — sit
in a single horizontal row, centered on a matte backdrop. Each
tile carries a Material-style monochrome SVG icon above an
uppercase label and a bracketed keybind hint.

This directory is **repo-local**. The user's `~/.config/wlogout/` is
never written. wlogout runs against `<repo>/wlogout/` via `-l` and
`-C`.

## Files

| Path                         | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| `layout`                     | Five raw JSON entries (no comments). One per tile.         |
| `style.css`                  | HANCORE chassis, matte backdrop, per-tile icon bindings.   |
| `icons/lock.svg`             | Lucide-style outlined padlock, 24×24 viewBox, stroked at `#e0e0e0`. |
| `icons/logout.svg`           | Outlined door + exit arrow.                                 |
| `icons/suspend.svg`          | Outlined crescent moon.                                     |
| `icons/reboot.svg`           | Outlined circular-arrow refresh.                            |
| `icons/shutdown.svg`         | Outlined power symbol.                                      |

The icons are Devvychrome-specific monochrome SVGs stroked at
`text.primary` luminance (`#e0e0e0`) with `stroke-width: 1.5`,
independent from the stock wlogout icons at
`/usr/share/wlogout/assets/`. Keeping them repo-local lets the theme
own the icon language end-to-end. Stroked geometry renders crisper
than filled paths at this scale and gives the "blueprint instrument"
feel.

## How wlogout actually renders a tile

Two facts from `wlogout(5)` and the wlogout source drove this design:

1. **The button is a single-line `GtkLabel`.** wlogout creates each
   tile via `gtk_button_new_with_label()`, whose internal label is
   single-line. Newlines (`\n`) in the layout's `text` field collapse
   to spaces. There is no reliable multi-line label.
2. **`width` and `height` per layout entry are not tile dimensions.**
   They are 0.0–1.0 fractions controlling **where the label sits
   inside the tile**. Default `width: 0.5, height: 0.9` →
   horizontally centered, near the bottom.

Therefore the canonical wlogout pattern (also used by `/etc/wlogout/style.css`):

- **Icon** → CSS `background-image` per `#<label>` selector.
- **Label** → single-line `text` field, positioned via the layout's
  `height` fraction.

This sheet follows that pattern.

## Tile design

```
┌────────────────────┐
│                    │
│         ▢▢         │   ← SVG icon, 96 px, positioned at 34% from top
│        ▢▢▢▢        │     (`background-position: center 34%`)
│        ▢▢▢▢        │     stroked at #e0e0e0, stroke-width 1.5
│                    │
│                    │
│   LOCK   [L]       │   ← single-line label at height: 0.80
│                    │     (uppercase, 15 px, 1.8 px letter-spacing)
└────────────────────┘
```

- **Tile geometry**: ≈ 240 × 260 on 1440 p ultrawide (the theme's
  primary target). Margins are absolute (`360 px` top/bottom,
  `24 px` between tiles); `min-width: 240px` and `min-height: 260px`
  floor the tile so the row never collapses. Wider screens get more
  horizontal breathing room either side; the strip itself stays a
  fixed pixel width.
- **Icon**: 24×24 viewBox Lucide-style outlined SVG, rendered at
  96 × 96, stroked at `#e0e0e0` with `stroke-width: 1.5`. The
  earlier Nerd-Font glyph approach failed because
  `CaskaydiaCove Nerd Font Propo` is not installed on stock
  Omarchy; the earlier filled-SVG approach rendered too soft.
  Stroked geometry is deterministic and crisp at any scale.
- **Label**: single line, `LABEL   [KEYBIND]`. wlogout's button
  label is single-line, so the keybind hint is inline-spaced rather
  than stacked. Triple space gives a visible gap.
- **Chassis**: 1 px solid `#2a2a2a` outline (not the heavier 2 px
  `#111` HANCORE — at this tile size the heavier border merged
  with the matte backdrop and the tile lost its edge). Layered
  `box-shadow` supplies industrial card depth: an engraved 1 px
  base, a soft 6 px outer elevation, and a barely-there 1 px
  inset top-edge bevel.
- **Hover**: cell fill `#1d1d1d → #242424`, label `#c8c8c8 → #e0e0e0`.
  The icon stays at `#e0e0e0` (it's the cell's identifier; the cell
  lift is the affordance). No scale, no glow, no border-colour change.
- **Active**: fill drops to `#2b2b2b` for the duration of the press.
- **Focus**: 1 px `#5a5a5a` border ring on the focused tile.

## Dependencies

| Tool                  | Required for       | Notes                                             |
| --------------------- | ------------------ | ------------------------------------------------- |
| `wlogout`             | the sheet itself   | `sudo pacman -S wlogout` on Arch / Omarchy.       |
| `omarchy-system-*`    | tile actions       | Provided by Omarchy. The sheet is a thin shim.    |

No fonts beyond what the system already has — text is plain ASCII,
icons are SVG.

## Scratch preview

The sheet runs entirely from this repo without touching
`~/.config/wlogout/`:

```bash
# 1. (Optional) Confirm wlogout is installed.
which wlogout || sudo pacman -S wlogout

# 2. Open the sheet using the repo-local layout and stylesheet.
#    -b 5  five buttons per row (single horizontal strip)
#    -P 1  xdg protocol (regular window — friendlier in dev)
#    -n    do not span across multiple monitors
wlogout -l "$(pwd)/wlogout/layout" \
        -C "$(pwd)/wlogout/style.css" \
        -b 5 -P 1 -n

# 3. Dismiss without firing an action.
#    Mouse: click outside any tile. Keyboard: Esc.
```

Iterate by editing `wlogout/style.css`, `wlogout/layout`, or any
SVG under `wlogout/icons/` and re-running step 2 — wlogout reads
its config fresh on every launch, so there's no daemon to reload.

> **Heads-up:** every tile is wired to the *real* action.
> Previewing `shutdown` will shut the machine down. Use the
> visuals-only dry run below for safe iteration.

### Visuals-only dry run

```bash
# Drop-in copy of the layout where every action is `true` (no-op).
sed -E 's/("action" : ").+(",)/\1true\2/' wlogout/layout \
  > /tmp/wlogout-devvychrome-dryrun.layout

wlogout -l /tmp/wlogout-devvychrome-dryrun.layout \
        -C "$(pwd)/wlogout/style.css" \
        -b 5 -P 1 -n
```

Click each tile; nothing happens beyond the sheet closing.

## Install

Two install styles, depending on how aggressively the user wants
Devvychrome wired into their session.

### Style 1 — repo-local launcher (recommended for daily drivers)

Bind a key in Hyprland to invoke wlogout against this repo directly.
No files are copied; the repo is the source of truth.

```conf
# ~/.config/hypr/bindings.conf  (user file, not stock omarchy)
bind = SUPER, Escape, exec, wlogout \
    -l ~/Projects/source_code/omarchy-devvychrome-theme/wlogout/layout \
    -C ~/Projects/source_code/omarchy-devvychrome-theme/wlogout/style.css \
    -b 5 -P 1 -n
```

Adjust the path to wherever this repo lives on the user's machine.
GTK resolves the relative `url("icons/...")` references in
`style.css` against the stylesheet's directory — so the icons
subdir is found automatically.

### Style 2 — copy into `~/.config/wlogout/`

For users who prefer a bare `wlogout` invocation (e.g. a hardware
power-button handler that hard-codes the binary name):

```bash
mkdir -p ~/.config/wlogout
cp -r wlogout/layout wlogout/style.css wlogout/icons \
      ~/.config/wlogout/
```

> **Important:** the `icons/` subdirectory must come along. GTK CSS
> resolves the relative `url("icons/...")` references against
> `~/.config/wlogout/style.css`, so the icons must live at
> `~/.config/wlogout/icons/`.

After install, `wlogout` with no flags uses the Devvychrome sheet
(modulo the buttons-per-row default — pass `-b 5` if your trigger
allows). This style **does** overwrite anything previously in
`~/.config/wlogout/`; back that up first if it matters.

## Test commands

Once installed (either style):

```bash
# Visual check — all five tiles render, identical at rest.
wlogout -b 5 -P 1 -n            # Style 2
# or the launcher form from Style 1

# Keyboard reach — each letter triggers its tile.
# l → lock     e → logout    u → suspend    r → reboot    s → shutdown
# Press Esc to dismiss without firing.
```

Verify:

- Backdrop is matte `#111` at ~0.92 opacity. No blur, no frosted
  overlay.
- Five tiles render as a single horizontal row, centered on screen,
  each ≈ 240 × 260 on the 1440 p ultrawide target.
- Each tile shows a clear stroked monochrome SVG icon in the upper
  portion and an uppercase label with a bracketed keybind in the
  lower portion (`LOCK   [L]`, etc.). Icon stroke is `#e0e0e0` at
  `stroke-width: 1.5`.
- At rest, label is `#c8c8c8`, fill is `#1d1d1d`, border is 1 px
  `#2a2a2a` with a 4 px corner radius. Layered `box-shadow`
  produces engraved + softly-elevated card depth. No accent colour.
- Hover lifts the tile fill to `#242424` and label to `#e0e0e0`.
  The icon's colour does not change. No scale, no glow.
- Pressing a tile drops the fill to `#2b2b2b`.
- Tabbing through the tiles exposes a 1 px `#5a5a5a` border ring on
  the focused tile, without resizing.
- Esc dismisses the sheet without firing any action.

## Revert

The repo-local launcher (Style 1) leaves `~/.config/wlogout/`
untouched; remove the `bind = …` line and the integration is gone.

For Style 2:

```bash
rm -rf ~/.config/wlogout
```

That returns wlogout to its built-in defaults. Devvychrome's other
components (waybar, eww, mako, colours) are unaffected.
