# Devvychrome — Waybar fragment (Media Rail v1)

This directory holds the v1 Media Rail Waybar surface. It is
intentionally a *fragment*: never copy these files into
`~/.config/waybar` from automation. The supported way to evaluate
them is a scratch Waybar instance pointed at the repo.

## Files

- `config.jsonc.fragment` — self-contained Waybar config that
  preserves the spirit of the HANCORE V2.1c layout while replacing
  the previous `mpris` element with the Devvychrome Media Rail.
- `style.css.fragment` — Devvychrome monochrome styling for the bar
  and the Rail.

The Rail invokes scripts from `../scripts/media/`.

## Required environment

The fragment references scripts via the `$DEVVYCHROME_REPO` env var
so the same files work regardless of where the repository is cloned.

```bash
export DEVVYCHROME_REPO="$(pwd)"   # run from the repo root
```

## Sanity-checking the scripts

Before launching a scratch Waybar, verify the rail's custom module
emits the JSON shape the bar expects.

```bash
export DEVVYCHROME_REPO="$(pwd)"

# now-playing.sh emits one JSON line. With media playing it should
# render as `<artist> · <title>` plus a discrete 8-cell progress
# ribbon inside the pango span; with no active player it should fall
# back to the recessed-dot idle payload.
DEVVYCHROME_REPO="$DEVVYCHROME_REPO" bash scripts/media/now-playing.sh
```

Static syntax check on every media script:

```bash
bash -n scripts/media/*.sh scripts/media/lib/*.sh
```

## Scratch preview

This loop never touches `~/.config/waybar`.

```bash
# 1. Materialize a scratch config under /tmp.
mkdir -p /tmp/devvychrome-waybar
cp waybar/config.jsonc.fragment /tmp/devvychrome-waybar/config.jsonc
cp waybar/style.css.fragment    /tmp/devvychrome-waybar/style.css

# 2. Export the repo path the fragment expects.
export DEVVYCHROME_REPO="$(pwd)"

# 3. Run a scratch Waybar that does not collide with the live one.
waybar -c /tmp/devvychrome-waybar/config.jsonc \
       -s /tmp/devvychrome-waybar/style.css
```

The scratch instance will draw a second top bar above (or stacked
with) the live one, depending on Hyprland's layer rules. To exit,
foreground the terminal running Waybar and press Ctrl-C.

To iterate, re-run the `cp` step and signal the scratch Waybar to
reload (or just Ctrl-C and relaunch).

## Merging into a live config (when ready)

Do this on a scratch Hyprland session, with a backup in hand:

```bash
cp -r ~/.config/waybar ~/.config/waybar.bak.$(date +%F)
```

Then, by hand:

1. Add `"group/devvychrome-media-rail"` to `modules-left` (or
   wherever the previous `mpris` entry lived) in
   `~/.config/waybar/config.jsonc`.
2. Copy the `group/devvychrome-media-rail` and `custom/now-playing`
   blocks from `config.jsonc.fragment`.
3. Lift the rules under the **Devvychrome Media Rail** header in
   `style.css.fragment` into `~/.config/waybar/style.css`.
4. Ensure `$DEVVYCHROME_REPO` is exported in the Hyprland session
   (e.g. via `~/.config/hypr/hyprland.conf` or a profile file) so
   the scripts resolve at bar startup.
5. `omarchy-restart-waybar` to apply.

## Dependencies

| Tool        | Required for                                  | Fallback if missing                       |
| ----------- | --------------------------------------------- | ----------------------------------------- |
| `playerctl` | `now-playing.sh`, `control.sh`, `menu.sh`, `progress.sh`, `art.sh`, `state.sh` | Rail renders empty / scripts exit silently |
| `rofi`      | `menu.sh` (right-click fallback)              | Menu does nothing                          |
| `curl` *or* `wget` | `art.sh` http(s) art fetch             | `art.sh` exits silently                    |
| `magick`/`convert` *or* `ffmpeg` | `art.sh` desaturation     | `art.sh` exits silently                    |

`art.sh` is consumed by the eww popup (v1.5) via
`art-or-placeholder.sh`.

## Visualization

Waybar v1 deliberately ships **no** music visualizer. The earlier
`custom/wave` module — first cava-driven, later a deterministic
text meter — caused capsule width and motion stability problems on
the bar surface. The 8-cell discrete progress ribbon emitted by
`now-playing.sh` carries the "rail is alive" signal without animation.

Real audio visualization is reserved for a future enhancement to the
eww popup, where graphical rendering (GTK widgets, drawing primitives)
is the right tool. Do not reintroduce a streaming visualizer to
Waybar.

## Fonts

The fragment expects a Nerd Font (JetBrainsMono Nerd Font is the
default) for the playback glyphs. Most Omarchy installs already
provide one. If glyphs render as `□`, install
`ttf-jetbrains-mono-nerd` (or any Nerd Font) and pick it up in
`style.css.fragment`'s top-level `font-family`.
