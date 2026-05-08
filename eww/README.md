# Devvychrome — Media Controls Popup (eww v1.5)

A monochrome, instrument-panel surface that exposes the active
MPRIS player's metadata, transport, sink volume, and progress.
Designed to read as a native extension of the Media Rail.

This directory is **repo-local**. The user's `~/.config/eww` is
never modified. eww runs against `<repo>/eww/` via `--config`.

## Files

| File                  | Purpose                                                  |
| --------------------- | -------------------------------------------------------- |
| `eww.yuck`            | Window, widgets, and state polling.                      |
| `eww.scss`            | Devvychrome monochrome styling for the popup.            |
| `art-placeholder.png` | 80×80 grayscale plate used when no album art is available. |

The popup invokes scripts from `../scripts/media/`:
`progress.sh`, `volume.sh`, `art-or-placeholder.sh`, `control.sh`,
and (via `popup.sh`) `menu.sh` as the rofi fallback.

## Dependencies

| Tool        | Required for                                | Fallback if missing                  |
| ----------- | ------------------------------------------- | ------------------------------------ |
| `eww`       | the popup itself                            | `popup.sh` falls back to rofi menu   |
| `playerctl` | metadata, transport, progress               | popup renders empty / muted state    |
| `wpctl`     | sink volume (PipeWire — Omarchy default)    | `volume.sh` falls back to `pactl`    |
| `pactl`     | sink volume (PulseAudio fallback)           | `volume.sh` becomes a quiet no-op    |
| `magick` *or* `convert` | (re)generating `art-placeholder.png` if missing | placeholder must already exist  |

`eww` is the one new dependency vs. v1. Install with
`sudo pacman -S eww` on Arch / Omarchy.

## Architecture

```
Waybar rail
  └── on-click-right ─→ scripts/media/popup.sh
                            │
                            ├── eww present?
                            │     └─ eww --config <repo>/eww toggle media-controls
                            │           └── window reads:
                            │                 progress.sh, volume.sh,
                            │                 art-or-placeholder.sh,
                            │                 playerctl metadata
                            │           └── buttons run:
                            │                 control.sh {prev,play-pause,next}
                            │                 volume.sh set <n>
                            │
                            └── eww missing?
                                  └─ menu.sh  (rofi v1 fallback)
```

The popup's window is `:focusable false` and `:stacking "overlay"`.
It does not steal focus from the work surface, and it sits above
normal windows but below other overlays.

## Scratch preview

```bash
# 1. Start a daemon scoped to this repo's config dir.
eww --config "$(pwd)/eww" daemon

# 2. Open the popup. (popup.sh does this for you when bound to the
#    rail; the explicit form below is the manual equivalent.)
eww --config "$(pwd)/eww" open media-controls

# 3. Iterate on eww.scss / eww.yuck, then reload.
eww --config "$(pwd)/eww" reload

# 4. Close when done.
eww --config "$(pwd)/eww" close media-controls
eww --config "$(pwd)/eww" kill
```

The `--config` flag points eww at the repo's directory. Your
existing `~/.config/eww` (if any) is unaffected.

To preview the popup *together with* the v1 rail, run a scratch
Waybar instance per `waybar/README.md` and click the rail's right-
button — `popup.sh` will resolve the repo path automatically.

## Interaction model

- **Right-click the rail** → toggle popup open/closed.
- **Click outside the popup** → no-op (popup remains; right-click
  the rail again to close). Native click-outside-to-close support
  is deferred to a later revision.
- **Esc** → no-op (eww does not propagate Esc to overlay windows
  by default; `eww close media-controls` is the keyboard-fast way
  to dismiss).
- **Inside the popup:**
  - `◀` / `⏯` / `▶` buttons run `control.sh previous|play-pause|next`.
  - The volume scale runs `volume.sh set <n>` on release.
  - The progress scale is read-only (no seek in v1.5).

## Fallbacks

| Condition                       | Behaviour                                          |
| ------------------------------- | -------------------------------------------------- |
| `eww` missing                   | `popup.sh` runs the rofi menu (`menu.sh`).         |
| `eww` daemon not running        | `popup.sh` starts it lazily before opening.        |
| `playerctl` missing / no player | All metadata fields blank; popup still opens.      |
| Album art unavailable           | `art-placeholder.png` renders in the same slot.    |
| `wpctl` and `pactl` missing     | Volume slider at 50, set is a no-op.               |
| `art-placeholder.png` deleted   | `art-or-placeholder.sh` regenerates it lazily.     |

## Tuning the geometry

The window is anchored top-left at `x=24, y=32, width=380px`.
That places it just below the bar near the typical rail position
in the merged HANCORE layout. To match a different rail position,
edit the `:geometry` block in `eww.yuck` and `eww reload`. No
restart of the daemon is needed.
