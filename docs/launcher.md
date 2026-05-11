# Devvychrome — Launcher (Walker)

Omarchy ships [Walker](https://github.com/abenz1267/walker) as the
default application launcher. Devvychrome ships a **full Walker
theme** — its own `style.css` and `layout.xml` — installed
alongside Omarchy's stock `omarchy-default` theme and selected via
a one-line change in `~/.config/walker/config.toml`.

## Why a full theme directory, not a CSS override

An earlier revision of this work shipped a single `walker.css` at
repo root, installed to `~/.config/omarchy/themes/devvychrome/walker.css`
and `@import`ed at the top of upstream's
`omarchy-default/style.css`. That approach is what the Omarchy
template system is built for — but the cascade does not behave
the way the template suggests:

- Our `walker.css` is loaded **before** upstream's `style.css`
  rules. Any property of equal specificity that upstream sets
  later wins, regardless of source order in our file. We were
  forced to mark almost every layout rule `!important` to retain
  control, which produced a stylesheet that fought the framework.
- Direct testing confirmed that `omarchy-default/style.css`'s
  later-loaded rules reliably override any non-`!important` rule
  we set, even at equal selector specificity.

The cleaner architecture: ship a **peer theme** that owns its own
layout and styling end-to-end. No `@import`, no `!important`, no
cascade fights. The Devvychrome theme is selected by name; the
upstream theme stays untouched and remains a one-line rollback.

## Architecture

```
~/.local/share/omarchy/default/walker/themes/
├── omarchy-default/         ← upstream; UNTOUCHED
│   ├── layout.xml
│   └── style.css             (@imports current/theme/walker.css)
└── devvychrome/             ← installed from this repo
    ├── layout.xml            (verbatim copy of upstream — same widget tree)
    └── style.css             (Devvychrome styling, hardcoded palette)

~/.config/walker/config.toml
    theme = "devvychrome"     ← single switch
    additional_theme_location = "~/.local/share/omarchy/default/walker/themes/"
                              (already present in stock Omarchy config)
```

`additional_theme_location` is already set by stock Omarchy, so
Walker discovers the `devvychrome/` directory automatically. The
only live-config edit needed is the `theme = "devvychrome"` line.

## What's in the theme

### `layout.xml`

Near-verbatim copy of `omarchy-default/layout.xml`. The widget
tree (window → box-wrapper → search-container + content-container
+ keybinds → error) matches upstream; only the styling differs.

One additive change: a small `GtkLabel` with class `.input-prompt`
is inserted **before** the `GtkEntry` inside `SearchContainer`,
rendering a static `>_` prompt to the left of the typed text.
That label is what makes the search container read as a
command-line readout rather than a styled text field. It is a
sibling of `Input` (not a wrapper), so Walker's bind-by-id
behaviour against `id="Input"` is unaffected.

Keeping the layout otherwise identical means a future
`omarchy update` that changes the upstream widget tree won't
desync our theme — the worst case is a CSS class name moving,
which is fixable in `style.css` without touching layout. If
upstream restructures `SearchContainer`, re-add the
`.input-prompt` label in the new shape.

### `style.css`

Hardcoded to the Devvychrome palette (see `docs/design-language.md`),
no `@import`, no upstream colour variables. Visual treatment:

| Surface                | Treatment                                                                                          |
| ---------------------- | -------------------------------------------------------------------------------------------------- |
| `.box-wrapper`         | matte `#161616 / 0.96` fill, 1 px `#383838` outline, 4 px radius, 24 px pad, 200 px bottom margin, 5-layer card shadow |
| `.search-container`    | sunken `#0f0f0f` instrument panel, 1 px `#2a2a2a` outline, inset top etch (0.85), 8/16 px pad      |
| `.input-prompt`        | `>_` static label at `#8a8a8a` 18 px weight 700, 12 px right margin                                |
| `.input`               | JetBrainsMono mono at 18 px, `#e8e8e8`, bright `#f0f0f0` caret                                     |
| `.input placeholder`   | `#5f5f5f` (text.disabled) at full opacity                                                           |
| `.scroll`              | recessed `#121212` results panel, 1 px `#232323` inner border, inset shadow, 6 px pad              |
| `.item-box`            | 14 px left padding, **4 px transparent left border** (reserves space for the selection accent)     |
| `child:nth-child(even) .item-box` | `rgba(255,255,255,0.02)` tonal fill — extremely subtle row cadence, never a visible line  |
| `.item-text-box`       | 14 px vertical padding — taller, deliberate rows                                                    |
| `.item-text`           | `#e8e8e8` (text.primary), weight 600 — bright at all times                                          |
| `.item-subtext`        | `#8e8e8e` (text.muted) at 12 px — app description, restored from upstream's hidden state           |
| `.item-image`          | `0.95` scale, 14 px right margin, 18 px normal-icon size                                            |
| `child:hover .item-box`| `#1a1a1a` quiet hover fill                                                                          |
| `child:selected .item-box` | **4 px `#dcdcdc` left accent** + `#232323` fill + inset top bevel (0.07) + bottom etch (0.4) — active operational line |
| `.keybinds`            | 14 px top margin, 12 px top pad, 1 px `#232323` etched top rule                                    |
| `.global-keybinds > *` / `.item-keybinds > *` | matte `#141414` chip, 1 px `#262626` border, `#8a8a8a` 11 px — operational controls |
| `.error`               | `status.warning` (`#a0a0a0`), never red                                                             |

The typography stays constant between idle and selected rows on
purpose — type that changes on every keystroke is visual noise.
The selection chrome (left accent + fill step) carries the signal.

## Design intent

Devvychrome's read on a launcher is that it is **command-line
adjacent**: the input is a sunken instrument readout, the results
are a recessed catalogue, the chassis is a deliberate matte plate,
and the keybind hints at the bottom read as operational controls.

- **Recommended footprint.** ~950 × 520. Smaller windows still
  render but the instrument-panel proportions are tuned for this
  size — at 644 × 300 the chassis padding and 5-layer shadow read
  as overkill.
- **Anchored upward.** A 200 px `margin-bottom` on `.box-wrapper`
  shifts the centered chassis ~100 px up the screen, so the
  launcher reads as anchored in the upper working area rather
  than dead-center. Done via the theme so live Walker config
  stays untouched.
- **Sunken input with a prompt.** The search container is three
  luminance steps below the chassis (`#161616 → #0f0f0f`), framed
  by a 1 px outline plus a deepened inset top etch and tight 8 px
  vertical padding. A static `>_` prompt label sits to the left
  of the entry — that prompt is what makes the field read as a
  command-line readout, not a styled search box. The caret is
  pushed to `#f0f0f0` so the cursor position reads cleanly
  against the dark fill.
- **Recessed results panel.** The result list sits in a hollowed
  surface: `.scroll` carries a `#121212` fill, a 1 px `#232323`
  inner border and an inset top shadow. Rows are framed *inside*
  the chassis, not painted directly onto it.
- **Tonal row cadence.** `child:nth-child(even) .item-box` carries
  a `rgba(255,255,255,0.02)` overlay — a ~5-unit luminance step
  over the panel fill. Reads as engineered rhythm at glance
  distance, never as a visible separator line or table grid.
- **Terminal-cursor selection.** The selected row gets a 4 px
  `#dcdcdc` left accent — the visual idiom of a terminal cursor
  marking the armed command. The row fills to `#232323` and is
  framed by an inset top bevel (0.07) plus a bottom etch (0.4),
  so the active line has visible edge definition without leaning
  on glow or saturation.
- **Stable typography.** Item names stay at `#e8e8e8` weight 600
  through every state. The eye doesn't have to re-read on every
  arrow keystroke.
- **Restored subtext.** App descriptions are useful disambiguators
  ("Firefox / Web Browser") and read as command-catalogue prose.
  They sit one luminance band below the name and never compete
  with it.
- **Operational footer.** Keybind hints are wrapped in matte
  chips with a 1 px `#262626` border on top of a 1 px `#232323`
  etched rule that separates the footer from the result panel.
  Reads as labeled controls on a panel, not a hint strip.
- **Borders that disappear at distance.** `#2a2a2a` / `#232323`
  read as edges at conversational distance and as nothing at room
  distance.

## Cohesion with the rest of the theme

| Surface             | Shared element                                                          |
| ------------------- | ----------------------------------------------------------------------- |
| Waybar Media Rail   | `#1d1d1d` recessed surface, no border shift on state change             |
| Eww media popup     | 4 px radius, layered industrial shadow, 120 ms transition envelope      |
| Mako notifications  | Luminance-only hierarchy at the same three bands                        |
| Hyprlock            | Chassis at `backgrounds.primary` (`#161616`); foreground `text.primary` |
| wlogout             | Identical chassis idiom: 1 px `#2a2a2a` outline + layered card shadow   |

A user opening Walker right after dismissing the wlogout sheet
(or hovering over the Waybar media rail) sees the same instrument
language at every step.

## Install

```bash
# 1. Install the theme directory alongside Omarchy's stock theme.
mkdir -p ~/.local/share/omarchy/default/walker/themes/devvychrome
cp -r walker/themes/devvychrome/* \
      ~/.local/share/omarchy/default/walker/themes/devvychrome/

# 2. Switch Walker to the Devvychrome theme. This is the single
#    live-config edit the install needs.
sed -i 's/^theme = .*/theme = "devvychrome"/' ~/.config/walker/config.toml

# 3. Walker is a GTK4 daemon. Restart it (plus elephant) so the
#    new theme is loaded.
omarchy-restart-walker

# 4. Launch and verify.
omarchy-launch-walker
```

`additional_theme_location = "~/.local/share/omarchy/default/walker/themes/"`
is already set in stock Omarchy's `config.toml`, so Walker
discovers `devvychrome/` automatically once the directory exists.

> **Caution:** do not run `omarchy-refresh-walker` after this
> install. That script (intentionally) overwrites
> `~/.config/walker/config.toml` from the Omarchy default, which
> would reset `theme` back to `"omarchy-default"`. Re-run step 2
> if you ever need to refresh Walker's other configs.

## Preview / test

Walker accepts a `--theme` flag to launch one-shot against a named
theme — useful for iterating on `style.css` without flipping the
config every time:

```bash
walker --theme devvychrome --width 950 --maxheight 520 --minheight 520
```

The repo directory's `style.css` is **not** read by this flag
(Walker only looks up themes in the `additional_theme_location`
paths). To preview repo edits in this loop:

```bash
# Sync repo → install path
cp -r walker/themes/devvychrome/* \
      ~/.local/share/omarchy/default/walker/themes/devvychrome/

# Restart so the daemon re-reads the theme
omarchy-restart-walker

# Open one-shot against the theme by name
walker --theme devvychrome --width 950 --maxheight 520 --minheight 520
```

A few useful probes:

```bash
walker --theme devvychrome -m calc     -p "= " --width 950 --maxheight 520 --minheight 520
walker --theme devvychrome -m files    -p ". " --width 950 --maxheight 520 --minheight 520
walker --theme devvychrome -m websearch -p "@ " --width 950 --maxheight 520 --minheight 520
```

Verify, while looking at the launcher:

- Launcher sits anchored in the upper working area, not dead-
  centered. The visible chassis is shifted ~100 px above the
  vertical midpoint.
- Chassis is matte `#161616` at ~0.96 opacity with a 1 px `#383838`
  outline (visible against dark wallpapers, still industrial at
  room distance) and a layered card shadow. No bright frame,
  no glassy frost.
- Search container is three luminance steps darker than the
  chassis (`#0f0f0f`) with a deepened inset top etch and tight
  vertical padding (8 px). A static `>_` prompt is visible at
  the left, dimmer than the typed text. Input is monospace at
  18 px, `#e8e8e8`; caret is `#f0f0f0` (high contrast against
  the recessed fill); placeholder is `#5f5f5f`.
- Result list is framed as a recessed panel: a `#121212` fill,
  1 px `#232323` inner border, and an inset top shadow. The rows
  visibly sit *inside* the chassis, not on it.
- Each result row shows `[icon] NAME` at `#e8e8e8` weight 600,
  with a description below at `#8e8e8e` 12 px. Rows are tall
  (~52 px) and deliberate. Every other row sits a few luminance
  units higher than its neighbours — visible as cadence at
  glance distance, not as a separator line.
- Selected row shows a **4 px `#dcdcdc` left accent** and a
  `#232323` fill framed by an inset top bevel plus a bottom etch.
  Reads as an active operational line, not a generic GTK
  highlight. The accent's appearance and disappearance is the
  selection signal; typography does not change.
- Keybind hints at the bottom sit under a 1 px `#232323` etched
  top rule. Each hint label is rendered as a matte chip:
  `#141414` fill, 1 px `#262626` border, `#8a8a8a` 11 px text.
  Reads as operational controls.
- "No Results" placeholder is small and quiet, at `text.disabled`
  luminance.

## Rollback

To return Walker to the upstream `omarchy-default` theme without
touching anything else:

```bash
sed -i 's/^theme = .*/theme = "omarchy-default"/' ~/.config/walker/config.toml
omarchy-restart-walker
```

The Devvychrome theme directory at
`~/.local/share/omarchy/default/walker/themes/devvychrome/` stays
in place but is no longer consulted. To remove it entirely:

```bash
rm -rf ~/.local/share/omarchy/default/walker/themes/devvychrome
```

The upstream `omarchy-default/` theme is untouched throughout
this entire workflow.

## Omarchy compatibility notes

- **`omarchy update`** will not affect this theme. The Devvychrome
  theme lives in a sibling directory under
  `~/.local/share/omarchy/default/walker/themes/`; Omarchy's
  updater only refreshes `omarchy-default/`. (If a future Omarchy
  update changes Walker's widget tree, the upstream `layout.xml`
  and our copy will diverge — re-sync our `layout.xml` from the
  new upstream and re-test.)
- **`omarchy-refresh-walker`** overwrites
  `~/.config/walker/config.toml` from Omarchy defaults. Running it
  resets `theme` back to `"omarchy-default"`. Re-run step 2 of the
  install if this happens.
- **`omarchy theme set <name>`** for the Omarchy desktop palette
  is independent of Walker's theme. Walker stays on
  `"devvychrome"` regardless of which desktop palette is active.
  This is by design: Devvychrome's walker theme is hardcoded to
  the Devvychrome palette, so cross-palette use would look
  inconsistent.

## Anti-patterns

These are the temptations the theme exists to refuse — calling
them out so future revisions don't quietly re-introduce them:

- **A bright `@border`-style frame.** The Omarchy default uses the
  foreground colour as a border colour, producing a 2 px white
  frame around the launcher. Hold the border at `borders.default`
  band or below (`#2a2a2a` here).
- **A coloured selection.** Selection is luminance-only — a 3 px
  `#c8c8c8` left accent plus a `#1d1d1d` row fill, never a
  blue/purple/orange bar or pill.
- **Saturation in any state.** Even the error line stays in
  grayscale (`status.warning` `#a0a0a0`), never red.
- **Hiding the subtext.** App descriptions are useful
  disambiguators and read as command-catalogue prose. Keep them
  visible, just dimmer.
- **Type that changes on every keystroke.** Item-text colour and
  weight stay constant idle vs. selected. The chrome moves, the
  type does not.
- **Glassy / blurred chassis.** Matte, period. The launcher is a
  surface, not a lens.
- **Patching upstream's `omarchy-default/style.css` directly.**
  That file would be overwritten on `omarchy update`. The
  sibling-theme path used here survives upgrades and rolls back
  in a single line.
- **`@import`ing `~/.config/omarchy/current/theme/walker.css`.**
  Walker's `additional_theme_location` themes are expected to be
  self-contained. We tried the import-and-override approach in
  an earlier revision; the cascade ordering made it unreliable.
