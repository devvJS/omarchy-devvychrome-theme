# Devvychrome — Hyprlock

Devvychrome's lock screen is built in two parts that map onto Omarchy's
existing Hyprlock layering. Nothing in this directory changes any live
config when the repo is cloned; both pieces are opt-in.

## Files

| Path | Role | Live destination |
|------|------|------------------|
| `hyprlock.conf` (repo root) | Theme color variables | `~/.local/share/omarchy/themes/devvychrome/hyprlock.conf` (or `~/.config/omarchy/themes/devvychrome/hyprlock.conf` for a custom install) |
| `hypr/hyprlock.conf` | Full Devvychrome layout (lower-third time, subtle password field, no blur) | `~/.config/hypr/hyprlock.conf` |

The repo-root file follows Omarchy theme convention: it defines only
the five color variables Hyprlock expects (`$color`, `$inner_color`,
`$outer_color`, `$font_color`, `$check_color`). It is sourced by
`~/.config/hypr/hyprlock.conf` via the
`~/.config/omarchy/current/theme/hyprlock.conf` symlink whenever
Devvychrome is the active theme.

The `hypr/hyprlock.conf` override is optional. Stock Omarchy ships a
centered, blurred input-field with no time/date display; install this
file to get the lower-third Devvychrome layout instead. It still sources
the active theme's color vars at the top, so it composes cleanly with
any theme — Devvychrome will just look the most coherent under it.

## Visual intent

- **Blurred monochrome backdrop.** `blur_passes = 3` (matching stock
  Omarchy) softens Devvychrome wallpapers (`coastal-monolith`,
  `frame-decay`, `watcher`) into a fog. No shape overlay, no
  brightness dial — the wallpaper is meant to read.
- **Centered cluster.** Time, date, and auth field stack around the
  primary monitor's screen center: time on top (96pt JetBrainsMono
  Light), date as a quiet caption directly below (12pt), then the auth
  panel.
- **Large industrial auth panel.** 580×84, opaque `#080808` interior,
  2px `#2a2a2a` outline, no rounding, no shadow, no fade. Placeholder
  reads `enter the void` in mid-grey.
- **Primary-monitor only.** Secondary monitors show the blurred
  wallpaper with no time, no date, and no auth field — see the
  per-host pinning section below.
- **No animation, no neon, no glassmorphism.** Hierarchy is luminance
  only.

## Per-host monitor pinning

`hypr/hyprlock.conf` ships with the time, date, and auth field pinned
to a specific monitor (`monitor = DP-1`) so multi-monitor sessions
don't render a mirrored auth panel on every screen. The dimmed
wallpaper + dark overlay still cover every output, so secondary
monitors read as bare sealed surfaces with no readout.

This pin is a per-host setting and almost certainly does not match
your machine. Set it once after install:

```bash
# 1. List your outputs.
hyprctl monitors | grep -E "^Monitor"
#   Monitor DP-1 (ID 0):    ← example primary
#   Monitor HDMI-A-1 (ID 1): ← example secondary

# 2. Edit ~/.config/hypr/hyprlock.conf and set every `monitor = ...`
#    line to your primary's name. There are three of them — the time
#    label, the date label, and the input-field block.
```

Behavior of the `monitor` field:

| Block        | `monitor = <name>` | `monitor =` (empty) |
|--------------|--------------------|---------------------|
| `background` | only that output   | every output (default — keep this) |
| `shape`      | only that output   | every output (default — keep this) |
| `label`      | only that output   | mirrored to every output |
| `input-field`| only that output   | mirrored to every output |

If you want *only* the primary monitor lit during lock and the others
to stay dark, pin `background` and the `shape` overlay to your
primary's name as well — or replace `path = ...` in `background`
with `color = $color` to render flat `#161616` everywhere.

If you want the readout on every monitor (e.g. single-monitor setup,
or you genuinely want mirrored info), clear all three `monitor =`
lines back to empty.

## Install

### 1. Theme color variables

Treat this repo as an installable Omarchy theme. From the repo root:

```bash
# Custom install (preferred — survives `omarchy update`)
mkdir -p ~/.config/omarchy/themes/devvychrome
cp -r colors.toml hyprlock.conf backgrounds ~/.config/omarchy/themes/devvychrome/
# (plus any other theme assets you want to ship — alacritty.toml, btop.theme, etc.)

omarchy theme set devvychrome
```

After `omarchy theme set`, `~/.config/omarchy/current/theme` will point
at the Devvychrome directory and the color variables in `hyprlock.conf`
will resolve automatically.

### 2. Layout override (optional)

Only do this if you want the full Devvychrome lock screen rather than
the stock centered field. Back the live file up first — the stock
override is short and worth keeping.

```bash
cp ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak.$(date +%s)
cp hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
```

Hyprlock has no daemon to restart; the next lock invocation picks up
the new config.

## Preview without modifying live files

Hyprlock can be invoked against an alternate config with `-c`. From the
repo root:

```bash
# Preview the layout. Requires Devvychrome (or any theme that exposes
# ~/.config/omarchy/current/theme/hyprlock.conf) to be active so the
# `source =` line resolves.
hyprlock --immediate -c "$(pwd)/hypr/hyprlock.conf"
```

`--immediate` skips the grace period so the preview shows up instantly.
Authenticate normally to dismiss it.

If Devvychrome is not yet the active theme and you want a quick preview
without `omarchy theme set`, concatenate the color vars and the layout
into a temp file:

```bash
cat hyprlock.conf hypr/hyprlock.conf \
  | sed '/^source = ~\/\.config\/omarchy\/current\/theme\/hyprlock\.conf$/d' \
  > /tmp/devvychrome-hyprlock.conf
hyprlock --immediate -c /tmp/devvychrome-hyprlock.conf
```

## Revert

If the layout override doesn't fit, restore the backup:

```bash
ls ~/.config/hypr/hyprlock.conf.bak.* | tail -1 \
  | xargs -I{} cp {} ~/.config/hypr/hyprlock.conf
```

Or reset to Omarchy stock:

```bash
omarchy refresh config hypr/hyprlock.conf
```

## Manual test checklist

- [ ] `hyprctl configerrors` is clean after `omarchy theme set devvychrome`.
- [ ] Wallpaper is blurred (`blur_passes = 3`) and reads as a soft
      monochrome fog on every monitor.
- [ ] On the primary monitor, time, date, and auth field stack around
      screen center — time on top, date directly beneath, auth panel
      below.
- [ ] Secondary monitors show the blurred wallpaper only — no time,
      date, or auth field mirrored across.
- [ ] Auth-field interior is opaque dark (`#080808`); outline is dim
      (`#2a2a2a`), 2px, no rounding, no shadow. Placeholder reads
      `enter the void` in mid-grey.
- [ ] No animation when invoking or dismissing the lock.
- [ ] Failed-auth text renders in mid-grey, not red.
- [ ] Vertical offsets are tuned for ~1440px screen height. Nudge the
      `position = 0, NNN` Y values on the time/date/auth blocks if the
      cluster floats too high or crowds the bottom on a different
      resolution.
