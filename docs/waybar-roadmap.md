# Devvychrome — Waybar Roadmap

This document records the current Waybar baseline and the planned
Devvychrome refinements. No Waybar configuration ships from this
repository yet; the user's live config at `~/.config/waybar` must not
be modified by scaffolding work.

## Current base

The user is running the **HANCORE V2.1c** Waybar layout as a starting
point. Its module composition is:

- **Left:** Omarchy menu, Hyprland workspaces, idle inhibitor, pacman
  updates, tray drawer, MPRIS.
- **Center:** clock, idle indicator, notification silencing indicator,
  voxtype, screen recording indicator, Omarchy update, weather.
- **Right:** network, pulseaudio (output and input), power profiles,
  memory, cpu, battery.

The drawer-style tray group, persistent workspaces, and MPRIS module
are the most relevant patterns to preserve. The bar height is 27px
with a 2px top margin, which matches Devvychrome's preference for a
restrained, low-presence top edge.

## Planned modules

The Devvychrome target layout keeps the spirit of the V2.1c base but
collapses several decorative elements.

1. **workspaces** — Hyprland workspaces with grayscale glyphs.
2. **clock** — single-line time, calendar tooltip on hover.
3. **tray** — drawer-style, expanded on hover only.
4. **network** — icon-only, tooltip carries throughput detail.
5. **bluetooth** — icon-only, hidden when no adapter is present.
6. **audio** — output and input grouped; scroll for volume.
7. **battery** — only rendered when a battery is present.
8. **Devvychrome Media Rail** — supersedes the earlier "now-playing"
   and "music visualizer" entries. See [Devvychrome Media Rail](#devvychrome-media-rail).

## Devvychrome Media Rail

### Background

Omarchy issue [#1750](https://github.com/basecamp/omarchy/issues/1750)
("Add Music Visualization with Wave Bar and Media Controls Popup")
proposed an audio-reactive Waybar element with a popup transport
control. It was closed as *not planned* for Omarchy core. Devvychrome
adopts the capability as a theme-level enhancement, rebuilt around a
restrained monochrome aesthetic.

The Media Rail is conceived as an instrument panel for media — a
compact, legible status surface and an on-demand control surface —
not a music app embedded in the bar.

### Goal

A two-tier surface:

- **Rail (always-on, in Waybar).** Compact waveform or progress
  ribbon, with concise now-playing metadata. Monochrome, low-motion,
  unobtrusive when nothing is playing.
- **Popup (on demand).** A focused, monochrome controls panel
  exposed on click or hover dwell.

### Rail (Waybar surface)

- Compact waveform or progress display, six to ten cells wide.
- Now-playing metadata: short, truncated `Artist — Title` label.
- MPRIS-driven via `playerctl`; Spotify is a first-class target but
  no Spotify-specific code path is required.
- Click or hover dwell opens the popup.
- Scroll up / scroll down → previous / next track.
- Hidden or collapsed to a single dot when no media is playing.

### Popup (Devvychrome Media Controls)

- Track title (primary luminance band).
- Artist (secondary luminance band).
- Album, when available (muted band).
- Album art, when available, rendered in true grayscale and rounded
  to fit a small thumbnail (≈ 96–128 px). Falls back to a flat
  Devvychrome plate when no art is available.
- Transport row: previous, play/pause, next.
- Volume slider, bound to the active sink (not strictly to the
  player; the player's own volume is unreliable across clients).
- Track progress bar with elapsed and remaining time, updated at
  ~1 Hz.

### Aesthetic constraints

- **True monochrome.** Saturation is zero across the entire surface.
  Album art is desaturated before display.
- **No Spotify green.** Ever. Including in the play button.
- **No RGB, no neon, no rave equalizer.** The waveform reads as an
  oscilloscope, not a frequency display.
- **No clutter.** No cover-art halos, no animated gradients, no
  marquee scrolling text.
- **Instrument-panel feel.** Discrete controls, soft surfaces,
  weighty type. The popup should feel like flipping open a piece
  of equipment, not opening a media app.

### Implementation options evaluated

1. **Waybar custom modules + `playerctl` scripts.** Pure Waybar:
   `custom/now-playing` emits Waybar JSON from a polling script that
   wraps `playerctl metadata`; `on-click` runs a script that toggles
   the popup. Lowest risk — no new daemon, no new dependency beyond
   `playerctl`. Limitation: Waybar tooltips are pango-only, so the
   popup itself must live elsewhere.

2. **CAVA-backed waveform module.** A `custom/wave` module that
   reads from `cava` (with `output.method = raw`) and renders
   grayscale block characters. Adds the atmospheric "real audio"
   layer the Rail wants. Cost: depends on a PipeWire monitor source
   being available; binds the visualizer to system audio rather
   than the player. Pairs with option 1 rather than competing
   with it.

3. **eww popup.** [Eww](https://github.com/elkowar/eww) renders a
   real GTK popup with custom CSS, image support (suitable for
   desaturated album art), live progress bars, and click handlers.
   Best fit for the Media Controls popup. Cost: an extra
   long-running daemon (`eww daemon`), a config file in the repo,
   and a small amount of integration glue (Waybar `on-click` calls
   `eww open --toggle media-controls`). Medium risk.

4. **ags popup.** [Aylur's GTK Shell](https://github.com/Aylur/ags)
   covers the same surface as eww via JS/TS. More programmable,
   heavier runtime, less common in Omarchy installs. Redundant with
   eww for this use case; only worth revisiting if Devvychrome
   eventually wants a much richer panel system.

5. **rofi fallback popup.** Text-only menu of transport actions
   (`previous`, `play/pause`, `next`, players to switch to). Cannot
   render album art, progress, or live state, but is keyboard-first
   and trivial to invoke. Appropriate as a keyboard-triggered
   fallback, not the daily popup.

6. **Fully custom shell/Python helper scripts.** Not a popup option
   in their own right — these underpin every option above. A
   `scripts/media/` library wraps `playerctl`, normalizes MPRIS
   metadata, fetches and desaturates album art, and emits whatever
   the rendering layer needs (Waybar JSON, eww state, rofi entries).

### Recommended v1 approach

Lowest-risk, repo-local, no live config modification.

- **Rail:** option 1 (Waybar custom module + `playerctl` scripts),
  with option 2 (`cava`) as an optional companion module behind a
  feature flag. Option 6 (helper scripts) provides the substrate.
- **Popup in v1:** *deferred*. The v1 release uses Waybar's pango
  tooltip to surface track, artist, album, and current progress.
  Click toggles play/pause; scroll handles next/previous. No new
  daemons enter the picture.
- **Popup in v1.5:** option 3 (eww) introduces the real Media
  Controls popup, including grayscale album art and the volume
  slider. This lands on its own feature branch only after the v1
  rail is stable.
- **rofi fallback (option 5):** ships in v1 as a keyboard-only
  entrypoint (`scripts/media/menu.sh`) for cases where the popup
  is unavailable or undesired.
- **Rejected:** option 4 (ags), as redundant with eww for this
  scope.

This keeps v1 inside Waybar's native capability envelope, defers
the GTK popup until the data plane is proven, and avoids any
dependency Omarchy users do not already have.

### Repo layout for v1

All work stays inside this repository. Nothing is installed.

```
waybar/
  config.jsonc.fragment       # candidate module definitions only
  style.css.fragment          # candidate styling only
scripts/media/
  now-playing.sh              # playerctl → Waybar JSON
  wave.sh                     # cava → grayscale ribbon (optional)
  control.sh                  # play-pause / next / previous / toggle
  menu.sh                     # rofi fallback
  art.sh                      # album-art fetch + desaturate
```

The `.fragment` suffix is intentional: these are not drop-in
replacements for a full `~/.config/waybar/config.jsonc`. They are
authored to be merged into the user's live config by hand on a
scratch session.

### Manual preview instructions

Preview without disturbing the live bar by running a second Waybar
instance pointed at the repo files. From the repo root:

```bash
# Materialize a scratch config under /tmp from the fragments.
mkdir -p /tmp/devvychrome-waybar
cp waybar/config.jsonc.fragment /tmp/devvychrome-waybar/config.jsonc
cp waybar/style.css.fragment    /tmp/devvychrome-waybar/style.css

# Run a scratch Waybar that does not collide with the live one.
waybar -c /tmp/devvychrome-waybar/config.jsonc \
       -s /tmp/devvychrome-waybar/style.css
```

Iterate, then exit the scratch instance. The user's
`~/.config/waybar` is never touched by this loop.

For the v1.5 eww popup, preview similarly with `eww --config
$(pwd)/eww` so the daemon reads only the repo's config.

### Fallback behavior

- **No media playing.** The rail collapses to a single muted dot
  glyph at `text.muted` luminance. The popup, if opened, shows a
  "no active player" plate at the same width, with disabled
  transport controls.
- **Album art unavailable.** The popup renders a flat Devvychrome
  plate at `surfaces.elevated` (`#2b2b2b`) sized to the album-art
  slot. No placeholder iconography, no text fallback.
- **`playerctl` missing or returning no MPRIS bus.** The custom
  module never renders. Helper scripts exit quietly with a
  non-zero status; Waybar logs once and moves on. The Rail must
  never crash the bar.
- **`cava` missing or no PipeWire monitor source.** The optional
  waveform module is silently disabled. The progress ribbon
  remains as the rail's primary visual element.
- **eww missing (v1.5+).** Click falls back to the rofi menu
  (`menu.sh`) so transport control remains reachable.

## Rejected approach

A tiny unicode-only visualizer — a handful of `▁▂▃▄▅▆▇` characters
animated next to the clock — is rejected as the Devvychrome music
surface.

It fails the brief in three ways:

1. **It is decorative, not functional.** It animates without
   offering control. Devvychrome is built for engineering
   workflows; bar real estate has to do work.
2. **It contradicts the instrument-panel philosophy.** The Media
   Rail is meant to read as a piece of equipment with a status
   readout and a control surface. A dancing-bar element reads as
   a music app's mood widget, which is the opposite tone.
3. **It cannot scale.** Once the popup, transport, art, and
   progress requirements are added, the unicode bar becomes
   vestigial — visual noise next to a real control surface. It
   is better to omit the decorative layer entirely than to ship
   it alongside the real thing.

The Rail may *include* a subtle waveform via `cava` (option 2),
but only as the visual layer of a real media surface — never as
the surface itself.

## Styling direction

- **Surface.** `#242424`, slightly transparent (≈ 0.85 alpha) on top
  of the desktop blur.
- **Text.** Devvychrome `text.primary` (`#e0e0e0`) for active modules,
  `text.muted` (`#9a9a9a`) for passive metadata.
- **Separators.** Single `1px` rules at `borders.inactive` (`#242424`).
- **Hover.** Surface lifts to `surfaces.elevated` (`#2b2b2b`); no
  color shift.
- **Active.** Surface lifts to `surfaces.focused` (`#343434`); border
  at `borders.active` (`#5a5a5a`) only when truly focused.
- **Typography.** Module hierarchy comes from font weight and tracking,
  not color.

## How this gets implemented safely

The repository must not overwrite `~/.config/waybar`. Work proceeds
in two stages along separate feature branches.

**v1 — Media Rail (Waybar-native).**

1. Branch off `develop` into `feature/waybar-media-rail-v1`.
2. Author module fragments and helper scripts under `waybar/` and
   `scripts/media/` (see the v1 layout above).
3. Preview via the scratch-Waybar workflow in *Manual preview
   instructions*; never copy fragments into `~/.config/waybar`
   from automation.
4. Diff against the user's live `~/.config/waybar` by hand, on a
   scratch Hyprland session, before merging to `develop`.
5. Promote to `main` once the rail is stable and screenshotted.

**v1.5 — Media Controls popup (eww).**

1. Branch off `develop` into `feature/media-controls-popup-eww`
   only after v1 has merged.
2. Add `eww/` config to the repo. Wire Waybar's `on-click` to a
   `eww open --toggle media-controls` command behind a feature
   flag in `waybar/config.jsonc.fragment`.
3. Validate fallbacks (rofi menu, no-art plate, no-player plate)
   before merging.

Until those candidate files exist in this repo, this document is
the authoritative description of intent.
