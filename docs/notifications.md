# Devvychrome — Notifications

Omarchy ships [Mako](https://github.com/emersion/mako) as the default
notification daemon. Devvychrome layers a monochrome chassis on top
of Mako's stock omarchy rules without replacing them.

## Architecture

Mako is launched per-session and reads a single config file. On
Omarchy that file is wired up as a symlink:

```
~/.config/mako/config            (symlink)
    → ~/.config/omarchy/current/theme/mako.ini

~/.config/omarchy/current/theme/  is populated by `omarchy theme set`
~/.local/share/omarchy/default/mako/core.ini   provides all baseline
    layout, timeouts, app rules (Spotify suppression, do-not-disturb
    mode, the Setup/Update/Keybindings on-button-left handlers, etc.)
```

The convention each theme follows:

```ini
include=~/.local/share/omarchy/default/mako/core.ini

# … colour overrides only …
```

This repo's `mako.ini` follows that pattern and additionally overrides
chassis dimensions and urgency tiers. Layout rules and per-app
behaviour from omarchy's core remain in effect — `omarchy update`
will not stomp anything since we never touch the core file itself.

## What's in `mako.ini`

- **Chassis**: `#1d1d1d` background, `#3a3a3a` 1px border, 2px corner
  radius, 340px wide, 8×12 padding. Compact card; subtle but legible.
- **Hierarchy**: title rendered with a pango span at `#e0e0e0`
  (text.primary), body inherits the chassis `text-color` of `#c8c8c8`
  (text.secondary). One step of luminance separates the two.
- **Progress meter**: `over #6f6f6f` — sits at text.disabled luminance
  so it never outshines the title.
- **Urgency tiers**: state is signalled by border step and title
  luminance, never by hue.

  | urgency  | border    | body text | timeout | title lift |
  |----------|-----------|-----------|---------|------------|
  | low      | `#2a2a2a` | `#9a9a9a` | 4 s     | inherits `#e0e0e0` |
  | normal   | `#3a3a3a` | `#c8c8c8` | 5 s     | inherits `#e0e0e0` |
  | critical | `#7a7a7a` | `#e0e0e0` | sticky  | `#ececec` (one notch up) |

## Install

Treat this repo as an installable Omarchy theme. Same pattern used
for the existing color/wallpaper assets:

```bash
# Custom-theme directory survives `omarchy update`.
mkdir -p ~/.config/omarchy/themes/devvychrome
cp -r colors.toml hyprlock.conf mako.ini backgrounds \
      ~/.config/omarchy/themes/devvychrome/
# (plus any other theme assets you intend to ship)

omarchy theme set devvychrome
```

After `omarchy theme set`, `~/.config/omarchy/current/theme/mako.ini`
will be the file from this repo. Restart the daemon to pick up the
new styling:

```bash
makoctl reload
```

If `makoctl reload` ever appears to do nothing (e.g. mako died), the
brute-force restart is:

```bash
pkill mako
mako &
```

## Preview without installing the theme

Mako registers on the session DBus as the singleton notification
service, so a true side-by-side preview isn't possible. The cleanest
ephemeral preview is to swap the live mako out for a scratch
instance pointed at the repo, run a couple of `notify-send` probes,
then restore.

```bash
# 1. Stop the live daemon.
pkill mako

# 2. Start a scratch mako pointed at this repo's config.
mako -c "$(pwd)/mako.ini" &

# 3. Send test notifications across all three urgency tiers.
notify-send -u low      "Devvychrome / low"      "diagnostic — quiet tier"
notify-send -u normal   "Devvychrome / normal"   "default — body text band"
notify-send -u critical "Devvychrome / critical" "sticky — brighter outline"

# 4. Restore the live daemon.
pkill -f 'mako -c .*devvychrome-theme/mako.ini'
mako &
```

This procedure does not touch any file under `~/.config/mako/` or
`~/.config/omarchy/current/theme/`. Only the daemon process itself is
restarted.

## Test commands once installed

After `omarchy theme set devvychrome`, send the same three probes
against the live daemon:

```bash
notify-send -u low      "low — quiet tier"      "border #2a2a2a, body #9a9a9a"
notify-send -u normal   "normal — default tier" "border #3a3a3a, body #c8c8c8"
notify-send -u critical "critical — sticky"     "border #7a7a7a, title lifted"
```

Verify:

- Every card is 340 px wide with a 1 px `#3a3a3a` border (or the
  appropriate per-urgency variant).
- The summary line is one luminance step brighter than the body.
- Critical does not auto-dismiss (timeout 0) and renders the title at
  `#ececec`.
- No accent colour appears at any urgency. Hierarchy is grayscale.
- Spotify track-change toasts remain suppressed (inherited from the
  omarchy core).

## Revert

If the styling needs to come off without uninstalling Devvychrome
entirely, switch to any other Omarchy theme:

```bash
omarchy theme set vantablack
makoctl reload
```

Or refresh just the mako side of the config:

```bash
omarchy refresh config mako   # if available in your omarchy version
```
