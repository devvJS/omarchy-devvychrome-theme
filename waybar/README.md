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
2. Copy the `group/devvychrome-media-rail`, `custom/now-playing`,
   and `custom/wave` blocks from `config.jsonc.fragment`.
3. Lift the rules under the **Devvychrome Media Rail** header in
   `style.css.fragment` into `~/.config/waybar/style.css`.
4. Ensure `$DEVVYCHROME_REPO` is exported in the Hyprland session
   (e.g. via `~/.config/hypr/hyprland.conf` or a profile file) so
   the scripts resolve at bar startup.
5. `omarchy-restart-waybar` to apply.

## Dependencies

| Tool        | Required for                                  | Fallback if missing                       |
| ----------- | --------------------------------------------- | ----------------------------------------- |
| `playerctl` | `now-playing.sh`, `control.sh`, `menu.sh`     | Rail renders empty / scripts exit silently |
| `cava`      | `wave.sh` (optional waveform layer)           | Waveform module disappears; ribbon stays  |
| `rofi`      | `menu.sh` (right-click fallback)              | Menu does nothing                          |
| `curl` *or* `wget` | `art.sh` http(s) art fetch             | `art.sh` exits silently                    |
| `magick`/`convert` *or* `ffmpeg` | `art.sh` desaturation     | `art.sh` exits silently                    |

`art.sh` is wired but not consumed in v1; the dependency table is
listed so the v1.5 popup branch starts from a known baseline.

## Fonts

The fragment expects a Nerd Font (JetBrainsMono Nerd Font is the
default) for the playback glyphs. Most Omarchy installs already
provide one. If glyphs render as `□`, install
`ttf-jetbrains-mono-nerd` (or any Nerd Font) and pick it up in
`style.css.fragment`'s top-level `font-family`.
