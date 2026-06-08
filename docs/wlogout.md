# Devvychrome — wlogout

Devvychrome's wlogout sheet is the **sealed-maintenance face** of the
desktop: matte backdrop, five operational tiles in a single
horizontal control strip, monochrome SVG icons over short uppercase
labels. No decoration, no celebration of the destructive action.

## Architecture

Omarchy does **not** ship or invoke
[wlogout](https://github.com/ArtsyMacaw/wlogout). The stock power
flow is:

```
omarchy-menu  →  walker dmenu (System submenu)  →  omarchy-system-*
```

wlogout, when present at all, is a **parallel** power surface —
typically bound to `Super+Escape`, `Ctrl+Alt+Delete`, or a hardware
power-button handler. This sheet styles wlogout for users who run
it alongside the walker flow and want both surfaces to read as the
same instrument family.

The sheet is a **thin shim**: every tile delegates to the same
script Omarchy's walker calls, so it inherits window-closing,
`uwsm stop`, and hyprlock-refresh behaviour without re-implementing
any of it.

```
wlogout -b 5 -P 1 -n
  │
  ├── -l <repo>/wlogout/layout    ──→  five entries, one per tile
  ├── -C <repo>/wlogout/style.css ──→  HANCORE chassis + backdrop
  ├── -b 5                        ──→  one horizontal row of five
  ├── -P 1                        ──→  xdg-shell window (regular surface)
  ├── -n                          ──→  do not span across monitors
  │
  └── on tile-press / keybind:
        lock     →  omarchy-system-lock
        logout   →  omarchy-system-logout
        suspend  →  systemctl suspend          (matches omarchy-menu)
        reboot   →  omarchy-system-reboot
        shutdown →  omarchy-system-shutdown
```

Nothing in `~/.config/wlogout/` is touched by the repo-local
install style; nothing in `~/.local/share/omarchy/` is touched at
all.

## What's in `wlogout/`

```
wlogout/
├── layout                # 5 raw JSON entries (no comments)
├── style.css             # HANCORE chassis + per-tile icon bindings
└── icons/
    ├── lock.svg          # Outlined padlock,      24×24, stroke #e0e0e0
    ├── logout.svg        # Outlined exit arrow,   24×24, stroke #e0e0e0
    ├── suspend.svg       # Outlined crescent moon
    ├── reboot.svg        # Outlined circular arrow
    └── shutdown.svg      # Outlined power symbol
```

## How wlogout actually renders — and why this design changed

The first two iterations of this sheet failed because they fought
the framework. Two facts from `wlogout(5)` and the wlogout binary
ended up shaping the final design:

1. **`width`/`height` in a layout entry are not tile dimensions.**
   Per `wlogout(5)`: *"height and width are values between 0.0 and
   1.0 that control the location of where text is displayed; the
   default width 0.5, height 0.9."* They position the label inside
   the tile, in normalized fractions. We use `height: 0.80` so the
   label sits clearly lifted from the bottom edge and the icon
   commands the upper third of the tile.
2. **wlogout's button is single-line.** Each tile is a
   `gtk_button_new_with_label`-style button, whose internal
   `GtkLabel` is single-line. Newlines (`\n`) in the layout's
   `text` field collapse to spaces. There is no reliable multi-line
   label without patching wlogout itself.

Combined, those mean the canonical wlogout pattern (also used by
`/etc/wlogout/style.css`) is:

- **Icon** → CSS `background-image` per `#<label>` selector.
- **Label** → single-line `text` field, positioned via the layout's
  `height` fraction.

This sheet follows that pattern. The icon language is repo-local
SVGs at `text.primary` luminance (`#e0e0e0`), Lucide-style outlined
(stroke geometry, not filled paths) with `stroke-width: 1.5`;
the label format is single-line `LABEL   [KEYBIND]` with
triple-space separation so the keybind reads as a hardware hint,
not as a continuation of the label.

## Tile content hierarchy

```
   ▢▢
  ▢▢▢▢               ← stroked SVG icon (96 × 96 px), positioned at
   ▢▢                  background-position: center 34%
                       stroke #e0e0e0, stroke-width 1.5

  LOCK   [L]         ← single-line label at height: 0.80
                       (uppercase, 15 px, 1.8 px letter-spacing,
                        triple-space gap before bracketed keybind)
```

The five tiles, left-to-right:

| Tile     | Icon              | Label             | Keybind |
| -------- | ----------------- | ----------------- | ------- |
| lock     | padlock           | `LOCK   [L]`      | `l`     |
| logout   | exit arrow        | `LOG OUT   [E]`   | `e`     |
| suspend  | crescent moon     | `SUSPEND   [U]`   | `u`     |
| reboot   | restart curve     | `REBOOT   [R]`    | `r`     |
| shutdown | power symbol      | `SHUTDOWN   [S]`  | `s`     |

## Geometry

| Property              | Value                                                    |
| --------------------- | -------------------------------------------------------- |
| Margin (top / bottom) | 360 px (absolute)                                        |
| Margin (left / right) | 24 px between tiles (absolute)                           |
| `min-width`           | 240 px                                                   |
| `min-height`          | 260 px                                                   |
| Tile fill             | `#1d1d1d` (`backgrounds.secondary`)                      |
| Tile border           | 1 px solid `#2a2a2a` (`borders.default`), 4 px radius    |
| Tile shadow           | layered: engraved `0 1px 2px rgba(0,0,0,1)` + soft elevation `0 6px 20px rgba(0,0,0,0.35)` + inset bevel `0 1px 0 rgba(255,255,255,0.04)` |
| Icon                  | stroked SVG, rendered 96 × 96, `background-position: center 34%`, stroke `#e0e0e0` at width 1.5 |
| Label position        | layout `width: 0.5`, `height: 0.80`                      |
| Font                  | `JetBrainsMono Nerd Font Propo` (mono fallback)          |
| Font size             | 15 px, weight 600, letter-spacing 1.8 px                 |

On the 1440 p ultrawide target the absolute margins produce a strip
of five ≈ 240 × 260 tiles centered horizontally with 24 px gaps. On
wider screens the strip retains the same pixel width and gains
horizontal breathing room either side; on narrower screens the
`min-` floors keep the tiles legible. In every case the row is one
short horizontal band — not five full-height columns.

## Design intent

Devvychrome's read on the wlogout problem is that **a power sheet
is operational instrumentation, not a celebration**. Most
third-party wlogout themes treat shutdown/reboot as hero cards —
large icons, saturated accents, hover bounces, oversized rounded
glass panels. Devvychrome takes the opposite position:

- **Five tiles, identical at rest.** Destructiveness is communicated
  by *position* (rightmost = most terminal) and by the *label*,
  never by colour or scale. The shutdown tile does not get a red
  ring; the lock tile does not get a "safe" green halo.
- **A control strip, not a card grid.** Tiles are short and dense;
  the row reads as a panel of mounted instrument keys. There is no
  outer card wrapper, no rounded chrome around the strip — the
  five tiles are themselves the rail.
- **Repo-local SVG icons.** The icon language is owned by the
  theme, not borrowed from font fallback. Earlier iterations used
  Nerd-Font glyphs in the button text; that broke on stock Omarchy
  because the chosen Nerd-Font variant wasn't installed and GTK
  fell through to a sans fallback. SVGs are deterministic.
- **Static icon, dynamic cell.** The icon is the tile's identifier
  and does not recolour on hover. The cell lift (`#1d1d1d → #242424`)
  is the affordance; the label brightening (`#c8c8c8 → #e0e0e0`) is
  the confirmation. The icon stays at `#e0e0e0` throughout — it is
  the cell's identifier, not part of the hover signal.
- **Matte, never glassy.** The backdrop is opaque enough to read as
  a surface (0.92), not a frosted lens. The desktop fades, it does
  not blur.
- **Engraved, not raised.** Each tile's HANCORE shadow is 1 px hard
  at full opacity — the reverse of a card lift. Tiles are *mounted
  into* the backdrop, not floating above it.
- **Low-motion hover.** 120 ms ease on background, colour, and
  border-colour only. Same envelope as the eww transport buttons.

The result is intended to feel like a sealed workstation entering
maintenance mode: utility-grade, deliberate, free of the visual
language of "fun" power menus.

## Cohesion with the rest of the theme

| Surface             | Shared element                                              |
| ------------------- | ----------------------------------------------------------- |
| Waybar Media Rail   | `#1d1d1d` recessed cell, hover → `#242424`, no border shift |
| Eww media popup     | 2 px `#111` HANCORE border, 4 px radius, 1 px shadow, 120 ms transitions |
| Mako notifications  | Glyph at `text.secondary`, label at `text.muted`, hover lifts to `text.primary` |
| Hyprlock            | Backdrop at `backgrounds.absolute` (`#111`); foreground at `text.primary` (`#e0e0e0`) |

The Material-design icon paths used here are visually adjacent to
the codepoints `omarchy-menu`'s walker uses for its System submenu
(`󰍃 󰒲 󰜉 󰐥`), so opening the wlogout sheet right after dismissing
the walker submenu reads as the same instrument family — even
though the rendering paths differ (font glyph vs. SVG).

## Tile ordering

Left-to-right, the strip reads from most-recoverable to most-terminal:

```
[ LOCK ]  [ LOG OUT ]  [ SUSPEND ]  [ REBOOT ]  [ SHUTDOWN ]
```

| Tile      | Reversibility                                              |
| --------- | ---------------------------------------------------------- |
| lock      | Re-enter the same session with a password.                 |
| logout    | Session ends; processes terminate; user-state preserved.   |
| suspend   | Hardware sleeps; on resume the session continues.          |
| reboot    | Full power cycle; user-state lost; OS returns.             |
| shutdown  | Full power cycle; user-state lost; OS does not return.     |

Suspend sits between logout and reboot because it preserves session
state but relinquishes hardware — strictly between "session loss"
and "system loss". The keybinds (`l e u r s`) follow the same row
order.

## Install

The repo's `wlogout/README.md` is the install reference. Two
patterns are supported:

1. **Repo-local launcher.** Bind a key (e.g. `Super+Escape`) to
   `wlogout -l <repo>/wlogout/layout -C <repo>/wlogout/style.css -b 5 -P 1 -n`.
   GTK CSS resolves the relative `url("icons/...")` references
   against the stylesheet directory automatically.
2. **`~/.config/wlogout/` install.** Copy `layout`, `style.css`, **and
   the `icons/` subdir** into `~/.config/wlogout/`. The icons must
   come along — GTK resolves `url("icons/lock.svg")` relative to
   the stylesheet's location at runtime.

## Preview without installing

```bash
wlogout -l "$(pwd)/wlogout/layout" \
        -C "$(pwd)/wlogout/style.css" \
        -b 5 -P 1 -n
```

Beware: every tile is wired to the real action. To iterate on
visuals without risking a real shutdown, use the dry-run recipe in
`wlogout/README.md` — it `sed`s the layout into a tmp file with
all actions replaced by `true`:

```bash
sed -E 's/("action" : ").+(",)/\1true\2/' wlogout/layout \
  > /tmp/wlogout-devvychrome-dryrun.layout

wlogout -l /tmp/wlogout-devvychrome-dryrun.layout \
        -C "$(pwd)/wlogout/style.css" \
        -b 5 -P 1 -n
```

## Test plan

After install (either style):

- **All five tiles render identically at rest.** `#c8c8c8` label,
  `#1d1d1d` fill, 1 px `#2a2a2a` border, 4 px radius, ≈ 240 × 260
  footprint on the 1440 p ultrawide target.
- **Each tile shows a clear monochrome SVG icon** in the upper
  third and a single-line `LABEL   [KEYBIND]` text in the lower
  third. Triple space between label and keybind is visible.
- **The row is a centered short strip.** Tiles share one
  horizontal row; there is no full-height column behaviour. The
  matte backdrop fills above and below the strip.
- **Hover lifts cleanly.** Cell `#1d1d1d → #242424`, label
  `#c8c8c8 → #e0e0e0`. The icon's colour does not change. No
  border-colour shift on hover alone, no scale, no shadow growth.
- **Active depresses.** Cell `#2b2b2b` for the duration of the
  press; reads as physically actuated.
- **Focus is keyboard-reachable.** Tab cycles through tiles; the
  focused tile shows a 1 px `#5a5a5a` border ring without
  resizing.
- **Keybinds fire the right tiles.** `l → lock`, `e → logout`,
  `u → suspend`, `r → reboot`, `s → shutdown`. `Esc` dismisses.
- **Backdrop is matte.** No blur, no frosted overlay; deep `#111`
  at ~0.92 opacity.

## Revert

For the repo-local launcher style: remove the `bind = …` line from
the user's Hyprland config. Nothing else exists to clean up.

For the `~/.config/wlogout/` install style:

```bash
rm -rf ~/.config/wlogout
```

That restores wlogout's built-in defaults. Devvychrome's other
components (waybar, eww, mako, colours) are unaffected.

## Anti-patterns

These are the temptations the sheet exists to refuse — calling
them out so future revisions don't quietly re-introduce them:

- **Multiline `text` fields.** wlogout's button label is
  single-line; `\n` collapses to a space. Don't try to stack the
  icon, label, and keybind via newlines. Use the SVG +
  single-line-label split instead.
- **Glyphs in the `text` field for the icon.** GTK's font fallback
  isn't deterministic on stock Omarchy (the Caskaydia Nerd-Font
  variant is not installed). Stick to repo-local SVGs.
- **Full-height columns.** Tiles stretching from the top to the
  bottom of the screen turn the sheet into a card grid; the
  monochrome chassis stops reading as instrumentation. Keep the
  row compressed via percentage margins.
- **Oversized icon or "hero" treatment** for any single action —
  particularly shutdown.
- **A red ring or red text** on the shutdown tile. Hierarchy is
  position and label, not colour.
- **Hover scale, hover translate, or hover shadow growth.** 120 ms
  ease on `background-color`, `color`, and `border-color` only.
- **A blurred, glassy, or gradient backdrop.** The backdrop is
  opaque matte, period.
- **Per-action accent colours** (cool blue for suspend, warm red
  for shutdown, etc.). Devvychrome holds saturation at zero —
  including here.
- **Replacing the per-tile action with a direct `loginctl` /
  `systemctl` call** to "simplify". Doing so silently bypasses the
  window-closing and uwsm-stop behaviour Omarchy's
  `omarchy-system-*` scripts perform.
- **JSON comments in `layout`.** wlogout's parser is strict
  newline-separated JSON objects; any `//` or `/* */` comment will
  break parsing. Design rationale lives in this file and in
  `style.css`'s top comment, never in `layout`.
