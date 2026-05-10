#!/usr/bin/env bash
# Devvychrome — wave.sh (deterministic v2)
#
# A deliberately non-reactive 8-cell meter for the Media Rail. Cava is
# gone. v1 used cava in raw ASCII mode; the resulting motion was too
# frantic for the brutalist aesthetic and the variable level-0 glyph
# (' ') caused the bar capsule to perceptually resize between frames.
#
# This script emits a fully deterministic ping-pong scan while a
# player is Playing, and a flat baseline otherwise. Frame width is a
# compile-time constant (BARS), so Waybar never reflows the capsule.
#
# Behaviour:
#   - Playing → a single peak (▇) sweeps left↔right with two trailing
#               steps (▅, ▃). 14 unique frames per cycle, ~7s per
#               cycle at TICK=0.5. Reads as a slow instrument scan.
#   - Paused / Stopped / no player → 8× ▁ baseline, repeated. Stable.
#
# The script is intentionally cheap: one playerctl status query per
# tick (~2 Hz) against the same player Now-Playing has selected, via
# lib/player.sh. No daemon, no streaming subprocess, no restart loop.

set -u

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

SELF_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck disable=SC1091
source "$SELF_DIR/lib/player.sh"

BARS=8
TICK=0.5

GLYPHS=( '▁' '▂' '▃' '▄' '▅' '▆' '▇' )
LVL_BASE=0   # ▁
LVL_TRAIL2=2 # ▃
LVL_TRAIL1=4 # ▅
LVL_PEAK=6   # ▇

baseline=""
for ((i=0; i<BARS; i++)); do baseline+="${GLYPHS[LVL_BASE]}"; done

# Ping-pong scan: peak position 0..BARS-1..0, repeating. With BARS=8
# this is 14 unique positions per cycle.
peak=0
direction=1

while :; do
    status=""
    if devvychrome_pick_player; then
        status=$(playerctl --player="$DEVVYCHROME_PLAYER" status 2>/dev/null || true)
    fi

    if [[ "$status" != "Playing" ]]; then
        printf '%s\n' "$baseline"
        sleep "$TICK"
        continue
    fi

    out=""
    for ((i=0; i<BARS; i++)); do
        d=$(( i - peak ))
        (( d < 0 )) && d=$(( -d ))
        case "$d" in
            0) lvl=$LVL_PEAK   ;;
            1) lvl=$LVL_TRAIL1 ;;
            2) lvl=$LVL_TRAIL2 ;;
            *) lvl=$LVL_BASE   ;;
        esac
        out+="${GLYPHS[lvl]}"
    done
    printf '%s\n' "$out"

    peak=$(( peak + direction ))
    if (( peak >= BARS ))    ; then peak=$(( BARS - 2 )); direction=-1; fi
    if (( peak < 0 ))        ; then peak=1;               direction=1;  fi

    sleep "$TICK"
done
