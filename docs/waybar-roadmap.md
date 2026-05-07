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
8. **now-playing** — MPRIS-driven, see below.
9. **music visualizer** — optional, see below.

## Now-playing behavior

Compact-by-default, expand-on-hover.

- **Default state.** A single glyph plus a short, truncated track label.
  No artist on the bar surface.
- **Tooltip on hover.** Full artist, full title, album, playback status,
  and the available transport actions.
- **Click.** `playerctl play-pause`.
- **Scroll up.** `playerctl previous`.
- **Scroll down.** `playerctl next`.
- **Right-click.** Optional helper menu — surface Spotify-specific
  actions (open the desktop client, like/save, jump to album) when
  the active player advertises a Spotify MPRIS bus.

The module should remain MPRIS-generic. Spotify is a first-class target
because that is the user's primary player, but `playerctl`-compatible
clients should all work without a separate code path.

## Music visualizer

The visualizer is optional and explicitly anti-spectacle. It must read
as a quiet oscilloscope, not a rave equalizer.

Tooling under consideration:

- **cava** with a custom ASCII gradient targeted at narrow bar geometry.
- A **custom Waybar module** that pipes a smoothed audio level into a
  short bar string.
- A standalone script outputting subtle grayscale block characters.

Aesthetic constraints:

- Compact — at most six to eight cells wide.
- Monochrome — luminance only; no color cycling, ever.
- Low motion — heavy smoothing; no peak-and-snap behavior.
- Subtle — never the loudest element on the bar.
- Hidden when no audio is playing.

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

The repository must not overwrite `~/.config/waybar`. The intended
workflow:

1. Branch off `develop` into `feature/waybar-devvychrome`.
2. Author candidate `config.jsonc` and `style.css` files inside this
   repository under (for example) `waybar/` once the design is settled.
3. Diff against the user's live `~/.config/waybar` *manually*; never
   copy in-place from automation.
4. Merge to `develop` only after a side-by-side review on a scratch
   Hyprland session.
5. Promote to `main` once the layout is stable and screenshotted.

Until those candidate files exist in this repo, this document is the
authoritative description of intent.
