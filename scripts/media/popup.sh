#!/usr/bin/env bash
# Devvychrome — popup.sh
#
# Toggles the Devvychrome Media Controls popup. Tries the eww v1.5
# popup first; falls back to the v1 rofi menu if eww is unavailable;
# exits silently if neither is present.
#
# Wired to the Media Rail's `on-click-right` handler in
# waybar/config.jsonc.fragment.
#
# Defensive design:
#   - eww runs from <repo>/eww with `--config` so the user's existing
#     ~/.config/eww (if any) is never touched
#   - the daemon is started lazily; if it's already running we reuse
#   - toggle is decided by inspecting `eww active-windows`, not by
#     blind --toggle, so we never end up in an ambiguous state
#   - any eww failure path silently falls through to the rofi menu;
#     transport remains reachable even when the popup cannot render

set -u

self_dir=$(cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(cd -- "$self_dir/../.." && pwd)
eww_dir="$repo_dir/eww"

if command -v eww >/dev/null 2>&1 && [[ -f "$eww_dir/eww.yuck" ]]; then
    # Bring the daemon up if it's not already responsive.
    if ! eww --config "$eww_dir" active-windows >/dev/null 2>&1; then
        eww --config "$eww_dir" daemon >/dev/null 2>&1 || true
        # Tiny grace period for the daemon socket to come up. Avoids
        # an immediate `open` racing the daemon's IPC bind.
        for _ in 1 2 3 4 5; do
            eww --config "$eww_dir" active-windows >/dev/null 2>&1 && break
            sleep 0.05
        done
    fi

    if eww --config "$eww_dir" active-windows 2>/dev/null \
            | grep -q '^media-controls\b'; then
        eww --config "$eww_dir" close media-controls >/dev/null 2>&1
    else
        eww --config "$eww_dir" open  media-controls >/dev/null 2>&1
    fi
    exit 0
fi

# Fallback: rofi-driven menu.
if [[ -x "$self_dir/menu.sh" ]]; then
    exec "$self_dir/menu.sh"
fi

exit 0
