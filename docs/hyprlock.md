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

- **Lower-third anchor.** The time sits roughly in the lower third of the
  screen; the date is a quiet caption directly beneath it. The status
  pretext (`SEALED`) above the time keeps the workstation legible as
  *closed* rather than *decorated*.
- **Subtle password field.** 360×44, 1px `#3a3a3a` outline, no rounding,
  no shadow, no fade. The placeholder reads `unlock` in mid-grey.
- **No blur on the wallpaper.** Devvychrome wallpapers
  (`coastal-monolith`, `frame-decay`, `watcher`) are already monochrome
  fog; blurring them flattens the instrumentation feel.
- **No animations, no neon, no glassmorphism.** Hierarchy is luminance
  only.

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
- [ ] Lock screen renders the time in the lower third, date directly
      beneath, `SEALED` pretext above.
- [ ] Password field outline is faint (`#3a3a3a`), 1px, no rounding.
- [ ] Background image is the active Devvychrome wallpaper, unblurred.
- [ ] No animation when invoking or dismissing the lock.
- [ ] Failed-auth text renders in mid-grey, not red.
- [ ] Layout still looks reasonable on a second monitor of a different
      resolution (the lower-third offsets are pixel-based; tune if
      needed).
