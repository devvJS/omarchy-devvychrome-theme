#!/usr/bin/env bash
# Devvychrome — control.sh
#
# Thin, defensive wrapper around playerctl for the Media Rail's
# Waybar click handlers and the rofi fallback menu.
#
# Usage: control.sh {play-pause|toggle|play|pause|next|previous|prev|stop}

set -u

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

# Resolve the active player before dispatching. Without this, a
# stopped Chromium tab can absorb the click and the user's actual
# music player never receives the transport command.
SELF_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck disable=SC1091
source "$SELF_DIR/lib/player.sh"

if ! devvychrome_pick_player; then
    exit 0
fi

case "${1:-}" in
    play-pause|toggle) playerctl --player="$DEVVYCHROME_PLAYER" play-pause >/dev/null 2>&1 ;;
    play)              playerctl --player="$DEVVYCHROME_PLAYER" play       >/dev/null 2>&1 ;;
    pause)             playerctl --player="$DEVVYCHROME_PLAYER" pause      >/dev/null 2>&1 ;;
    next)              playerctl --player="$DEVVYCHROME_PLAYER" next       >/dev/null 2>&1 ;;
    previous|prev)     playerctl --player="$DEVVYCHROME_PLAYER" previous   >/dev/null 2>&1 ;;
    stop)              playerctl --player="$DEVVYCHROME_PLAYER" stop       >/dev/null 2>&1 ;;
    *) exit 0 ;;
esac

# Nudge Waybar to repaint the now-playing module immediately rather
# than wait for the next 1 Hz tick. Matches "signal": 11 in
# config.jsonc.fragment. Signal 11 was chosen because the upstream
# HANCORE V2.1c live config already uses signals 7, 8, 9, and 10
# (custom/update, custom/screenrecording-indicator,
# custom/idle-indicator, custom/notification-silencing-indicator).
pkill -RTMIN+11 waybar >/dev/null 2>&1 || true
