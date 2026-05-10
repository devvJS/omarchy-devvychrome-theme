#!/usr/bin/env bash
# Devvychrome — wave.sh (deterministic v3, fixed-position)
#
# An 8-cell static meter for the Media Rail. No motion. No traveling
# peak, no ping-pong scan. The cells stay at fixed positions and the
# whole row simply selects one of three flat patterns based on the
# active player's status:
#
#   Playing  → ▃▃▃▃▃▃▃▃   (mid-low static — meter is "on")
#   Paused   → ▂▂▂▂▂▂▂▂   (one step lower — meter is "held")
#   else     → ▁▁▁▁▁▁▁▁   (baseline — meter is "off")
#
# Width is a compile-time constant (BARS), so Waybar never reflows
# the capsule. Updates fire at TICK seconds; if the status hasn't
# changed since the last frame, Waybar redraws an identical line.
#
# Active player is resolved via lib/player.sh, the same selector the
# Waybar rail and the eww popup use, so a stopped Chromium tab
# cannot pull the meter to baseline while Spotify is actually
# playing.
#
# Defensive: if playerctl is missing, exit silently. The Rail's
# progress ribbon (now-playing.sh) remains.

set -u

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

SELF_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck disable=SC1091
source "$SELF_DIR/lib/player.sh"

BARS=8
TICK=2

playing=""
paused=""
baseline=""
for ((i=0; i<BARS; i++)); do
    playing+="▃"
    paused+="▂"
    baseline+="▁"
done

while :; do
    status=""
    if devvychrome_pick_player; then
        status=$(playerctl --player="$DEVVYCHROME_PLAYER" status 2>/dev/null || true)
    fi

    case "$status" in
        Playing) printf '%s\n' "$playing"  ;;
        Paused)  printf '%s\n' "$paused"   ;;
        *)       printf '%s\n' "$baseline" ;;
    esac

    sleep "$TICK"
done
